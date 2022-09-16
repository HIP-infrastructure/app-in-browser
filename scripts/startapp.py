#!/usr/bin/env python3

import argparse
import yaml
from dotenv import load_dotenv
import subprocess
import os
import requests

# parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("app_name", help="name of the app to run")
parser.add_argument("server_id", help="server_id of the server to run the app on")
parser.add_argument("app_id", help="app_id of the server of the app")
parser.add_argument("hip_user", help="nextcloud username of the hip user to run the app as")
parser.add_argument("hip_password", help="nextcloud password of the hip user to run the app as")
parser.add_argument("nextcloud_domain", help="url of the nextcloud instance where the user data is located")
parser.add_argument("auth_backend_domain", help="url of the ghostfs authentication backend")
args = parser.parse_args()

container_name = f"{args.app_name}-{args.server_id}-{args.app_id}-{args.hip_user}"
server_name = f"{args.server_id}-{args.hip_user}"
context="./services"
app_env_path=f"{context}/apps/{args.app_name}/run.env"

#getting the app version from hip.yaml
with open('hip.yml') as f:
  hip = yaml.load(f, Loader=yaml.FullLoader)
if hip['apps'][args.app_name]:
  app_version=hip['apps'][args.app_name]['version']
else:
  print(f"Failed to run {args.app_name} because it wasn't found in hip.yml")
  exit(1)

# load variables from .env
load_dotenv()

# get the user token or password
hip_password=None
if os.getenv("DOCKERFS_TYPE") == "ghostfs":
  r = requests.get(args.auth_backend_domain + '/fs/token?hipuser=' + args.hip_user, auth=(os.getenv("AUTH_BACKEND_USERNAME"), os.getenv("AUTH_BACKEND_PASSWORD")))
  if r.status_code != 200:
      print(f"Received invalid token for user {args.hip_user}: {r}")
      exit(1)
  else:
      hip_password=r.json().get('token')
elif os.getenv("DOCKERFS_TYPE") == "davfs2":
  hip_password=args.hip_password
else:
  print(f"Failed to run {args.app_name} because an unsupported DOCKERFS_TYPE was provided")
  exit(1)

#run app container
ret_val = subprocess.check_call(["docker", "run", "-d", \
                                                  "-v", f"{server_name}_x11-unix:/tmp/.X11-unix", \
                                                  f"--network={server_name}_apps", \
                                                  *(["--device=/dev/dri:/dev/dri"] if os.getenv("CARD") != 'none' else []),
                                                  "--device=/dev/fuse:/dev/fuse", \
                                                  "--cap-add=SYS_ADMIN", \
                                                  "--security-opt", "apparmor=unconfined", \
                                                  "--runtime", os.getenv("RUNTIME"), \
                                                  "--ipc=host", \
                                                  "--name", container_name, \
                                                  "--hostname", container_name, \
                                                  "--restart", "on-failure",
                                                  "--env-file", ".env", \
                                                  *(["--env-file", app_env_path] if os.path.exists(app_env_path) else []),
                                                  "--env", "NVIDIA_VISIBLE_DEVICES=all", \
                                                  "--env", "NVIDIA_DRIVER_CAPABILITIES=all", \
                                                  "--env", "DISPLAY=:80", \
                                                  "--env", f"HIP_USER={args.hip_user}", \
                                                  "--env", f"HIP_PASSWORD={hip_password}", \
                                                  "--env", f"NEXTCLOUD_DOMAIN={args.nextcloud_domain}", \
                                                  "--env", f"APP_NAME={args.app_name}", \
                                                  "--add-host", "releases.hyper.is:127.0.0.1", \
                                                  "--add-host", "releases-canary.hyper.is:127.0.0.1", \
                                                  f"{os.getenv('CI_REGISTRY_IMAGE')}/{args.app_name}:{app_version}"])
assert ret_val == 0, f"Failed running {args.app_name}."
