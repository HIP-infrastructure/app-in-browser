from flask import Flask
from flask import request
from flask import jsonify
from flask_httpauth import HTTPBasicAuth
import pathlib
from werkzeug.security import generate_password_hash, check_password_hash
import json
import subprocess
import socket

__author__ = "Nathalie Casati"
__email__ = "nathalie.casati@chuv.ch"

app = Flask(__name__)
auth = HTTPBasicAuth()

# get relative path of secret file
SECRET_PATH = pathlib.Path(__file__).parent

# get relative path of docker-compose file
SCRIPT_PATH = pathlib.Path(__file__).parent.parent

# script directory
SCRIPT_DIR = "./scripts/"

def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    return s.getsockname()[0]

def get_credentials():
    with open(SECRET_PATH.joinpath("backend.secret"), mode='r') as secret:
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


@app.route('/control/server', methods=['GET'])
@auth.login_required
def control_server():
    # here we want to get the value of action, server_id and hip_user
    # (i.e. ?action=some-value&sid=some-other-value&hipuser=another-value)
    action = request.args.get('action')
    server_id = request.args.get('sid')
    hip_user = request.args.get('hipuser')

    if action is not None and server_id is not None and hip_user is not None:
        if action == "start":
            script = "launchserver.sh"
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
        output = subprocess.run(cmd, cwd=SCRIPT_PATH, text=True, capture_output=True)

        cmd = [SCRIPT_DIR + "getport.sh", server_id, hip_user]
        port = subprocess.run(cmd, cwd=SCRIPT_PATH, text=True, capture_output=True)

        response = {"output": {
                        "stdout": output.stdout.rstrip(),
                        "stderr": output.stderr.rstrip()},
                    "location": {
                        "url": get_ip(),
                        "port": port.stdout.rstrip()}}
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

    if action is not None and server_id is not None \
    and app_name is not None and app_id is not None \
    and hip_user is not None:
        if action == "start":
            script = "launchapp.sh"
        elif action == "stop":
            script = "stopapp.sh"
        elif action == "restart":
            script = "restartapp.sh"
        elif action == "logs":
            script = "viewapplogs.sh"
        elif action == "status":
            script = "appstatus.sh"
        elif action == "destroy":
            script = "destroyapp.sh"
        else:
            raise InvalidUsage('Invalid action', status_code=500)

        cmd = [SCRIPT_DIR + script, app_name, server_id, app_id, hip_user]
        output = subprocess.run(cmd, cwd=SCRIPT_PATH, text=True, capture_output=True)

        cmd = [SCRIPT_DIR + "getport.sh", server_id, hip_user]
        port = subprocess.run(cmd, cwd=SCRIPT_PATH, text=True, capture_output=True)

        response = {"output": {
                        "stdout": output.stdout.rstrip(),
                        "stderr": output.stderr.rstrip()},
                    "location": {
                        "url": get_ip(),
                        "port": port.stdout.rstrip()}}
        print(response)
        return jsonify(response)
    else:
        raise InvalidUsage('An unknown error has occured', status_code=500)


if __name__ == '__main__':
    app.run(port=8060)

