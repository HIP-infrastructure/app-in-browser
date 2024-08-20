from flask import Flask
from flask import request
from flask import jsonify
from flask_httpauth import HTTPBasicAuth
import pathlib
import yaml
from werkzeug.security import generate_password_hash, check_password_hash
import json
import subprocess
import socket
import os
from dotenv import load_dotenv

__author__ = "Nathalie Casati"
__email__ = "nathalie.casati@chuv.ch"

app = Flask(__name__)
auth = HTTPBasicAuth()

# get relative path of env files
ENV_PATH = pathlib.Path(__file__).parent

# get relative path of docker-compose file
DOCKER_PATH = pathlib.Path(__file__).parent.parent

# script directory
SCRIPT_DIR = "./scripts/"

load_dotenv(ENV_PATH.joinpath("backend.env"))

#get hip.yaml and filter apps that have their state set to alpha or off (False)
def get_hip():
  with open('hip.yml') as f:
    hip = yaml.load(f, Loader=yaml.FullLoader)

  for app, params in dict(hip['apps']).items():
    if params['state'] == 'alpha' or not params['state']:
      del hip['apps'][app]

  return hip

hip = get_hip()

def get_domain():
  return str(os.getenv('BACKEND_DOMAIN_APP_IN_BROWSER'))

def get_ip():
  s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  s.connect(("8.8.8.8", 80))
  return s.getsockname()[0]

def get_credentials():
  with open(ENV_PATH.joinpath("backend.secret"), mode='r') as secret:
    username, password = secret.read().split('@')
  return {username: password}


users = get_credentials()


class InvalidUsage(Exception):
  status_code = 400

  def __init__(self, message, status_code=None, payload=None):
    Exception.__init__(self)
    self.message = message
    if status_code is not None:
      self.status_code = status_code
    self.payload = payload

  def to_dict(self):
    rv = dict(self.payload or ())
    rv['message'] = self.message
    return rv


@app.errorhandler(InvalidUsage)
def handle_invalid_usage(error):
  response = jsonify(error.to_dict())
  response.status_code = error.status_code
  return response

@auth.verify_password
def verify_password(username, password):
  if username in users:
    return check_password_hash(users.get(username), password)
  return False


@app.route('/')
@auth.login_required
def index():
  return "Hello, %s!" % auth.username()

@app.route('/ok')
def health_check():
  return "Backend currently running on %s" % get_domain()

@app.route('/control/status')
@auth.login_required
def control_status():
  script = "dockerstatus.sh"

  cmd = [SCRIPT_DIR + script]
  output = subprocess.run(cmd, cwd=DOCKER_PATH, text=True, capture_output=True)

  response = {"output": {
                "stdout": output.stdout.rstrip(),
                "stderr": output.stderr.rstrip()},
              "location": {
                "domain": get_domain(),
                "ip": get_ip()}}

  return jsonify(response)

@app.route('/control/app/list')
@auth.login_required
def control_app_list():
  return jsonify(hip['apps'])

@app.route('/control/server', methods=['GET'])
@auth.login_required
def control_server():
  # here we want to get the value of action, server_id and hip_user
  # (i.e. ?action=some-value&sid=some-other-value&hipuser=another-value)
  action = request.args.get('action')
  server_id = request.args.get('sid')
  hip_user = request.args.get('hipuser')
  auth_groups = request.args.get('groups')

  keycloak_auth = False

  if action is not None and server_id is not None and hip_user is not None:
    if action == "start":
      script = "startserver.py"
      keycloak_auth = True
    elif action == "pause":
      script = "pauseserver.sh"
    elif action == "resume":
      script = "unpauseserver.sh"
    elif action == "stop":
      script = "stopserver.sh"
    elif action == "restart":
      script = "restartserver.sh"
    elif action == "logs":
      script = "viewserverlogs.sh"
    elif action == "status":
      script = "serverstatus.sh"
    elif action == "destroy":
      script = "destroyserver.sh"
    else:
      raise InvalidUsage('Invalid action', status_code=500)

    cmd = [SCRIPT_DIR + script, server_id, hip_user]
    if keycloak_auth:
      cmd.extend([auth_groups])

    if action != "status":
      print(cmd)

    output = subprocess.run(cmd, cwd=DOCKER_PATH, text=True, capture_output=True)

    cmd = [SCRIPT_DIR + "getport.sh", server_id, hip_user]
    port = subprocess.run(cmd, cwd=DOCKER_PATH, text=True, capture_output=True).stdout.rstrip()

    response = {"output": {
                  "stdout": output.stdout.rstrip(),
                  "stderr": output.stderr.rstrip()},
                "location": {
                  "domain": get_domain() if port else "",
                  "ip": get_ip() if port else "",
                  "session_id": port if port else "",
                  "url": f"{get_domain()}/session/{port}/" if port else ""}}

    if action != "status":
      print(response)

    return jsonify(response)
  else:
    raise InvalidUsage('An unknown error has occured', status_code=500)


@app.route('/control/app', methods=['GET'])
@auth.login_required
def control_app():
  # here we want to get the value of action, server_id, app_name, app_id and hip_user
  # (i.e. ?action=some-value&app=...etc.)
  action = request.args.get('action')
  app_name = request.args.get('app')
  server_id = request.args.get('sid')
  app_id = request.args.get('aid')
  hip_user = request.args.get('hipuser')
  hip_password = request.args.get('hippass')
  nextcloud_domain = request.args.get('nc')
  auth_backend_domain = request.args.get('ab')
  group_folders = request.args.get('gf')

  nextcloud_auth = False

  if action is not None and server_id is not None \
  and app_name is not None and app_id is not None \
  and hip_user is not None:
    if action == "start":
      script = "startapp.py"
      nextcloud_auth = True
    elif action == "pause":
      script = "pauseapp.sh"
    elif action == "resume":
      script = "unpauseapp.sh"
    elif action == "stop":
      script = "stopapp.sh"
    elif action == "restart":
      script = "restartapp.sh"
      nextcloud_auth = True
    elif action == "logs":
      script = "viewapplogs.sh"
    elif action == "status":
      script = "appstatus.sh"
    elif action == "destroy":
      script = "destroyapp.sh"
    else:
      raise InvalidUsage('Invalid action', status_code=500)

    cmd = [SCRIPT_DIR + script, app_name, server_id, app_id, hip_user]
    if nextcloud_auth:
      cmd.extend([hip_password or '', nextcloud_domain, auth_backend_domain, group_folders])

    if action !="status":
      print(cmd)

    output = subprocess.run(cmd, cwd=DOCKER_PATH, text=True, capture_output=True)

    cmd = [SCRIPT_DIR + "getport.sh", server_id, hip_user]
    port = subprocess.run(cmd, cwd=DOCKER_PATH, text=True, capture_output=True).stdout.rstrip()

    response = {"output": {
                  "stdout": output.stdout.rstrip(),
                  "stderr": output.stderr.rstrip()},
                "location": {
                  "domain": get_domain() if port else "",
                  "ip": get_ip() if port else "",
                  "session_id": port if port else "",
                  "url": f"{get_domain()}/session/{port}/" if port else ""}}

    if action !="status":
      print(response)

    return jsonify(response)
  else:
    raise InvalidUsage('An unknown error has occured', status_code=500)


if __name__ == '__main__':
  app.run(port=8060)

