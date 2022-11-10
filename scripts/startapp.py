#!/usr/bin/env python3

import argparse
import yaml
import subprocess
import os
import requests
import urllib.parse

# parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("app_name", help="name of the app to run")
parser.add_argument("server_id", help="server_id of the server to run the app on")
parser.add_argument("app_id", help="app_id of the server of the app")
parser.add_argument("hip_user", help="nextcloud username of the hip user to run the app as")
parser.add_argument("hip_password", help="nextcloud password of the hip user to run the app as")
parser.add_argument("nextcloud_domain", help="url of the nextcloud instance where the user data is located")
parser.add_argument("auth_backend_domain", help="url of the ghostfs authentication backend")
parser.add_argument("group_folders", help="list of group folders to mount")
args = parser.parse_args()

container_name = f"{args.app_name}-{args.server_id}-{args.app_id}-{args.hip_user}"
server_name = f"{args.server_id}-{args.hip_user}"
context="./services"
app_env_path=f"{context}/apps/{args.app_name}/run.env"

#loading hip.yaml
with open('hip.yml') as f:
  hip = yaml.load(f, Loader=yaml.FullLoader)
#loading hip.config.yaml
with open('hip.config.yml') as f:
  hip_config = yaml.load(f, Loader=yaml.FullLoader)
#getting the app version
if hip['apps'][args.app_name]:
  app_version=hip['apps'][args.app_name]['version']
else:
  print(f"Failed to run {args.app_name} because it wasn't found in hip.yml")
  exit(1)
#getting the registry
if hip_config['backend']['ci']['registry_image']:
  ci_registry_image=hip_config['backend']['ci']['registry_image']
else:
  print(f"Failed to run {args.app_name} because CI registry image wasn't found in hip.config.yml")
  exit(1)
#getting the tag
if hip_config['backend']['ci']['commit_branch']:
  ci_commit_branch=hip['backend']['ci']['commit_branch']
  if ci_commit_branch == "dev":
    tag = f"-{ci_commit_branch}"
  else:
    tag = ''
else:
  print(f"Failed to load tag it wasn't found in hip.config.yml")
  exit(1)
#getting the card
if hip_config['backend']['dri']['card']:
  card=hip_config['backend']['dri']['card']
else:
  print(f"Failed to run {args.app_name} because card wasn't found in hip.config.yml")
  exit(1)
#getting the runtime
if hip_config['backend']['dri']['runtime']:
  runtime=hip_config['backend']['dri']['runtime']
else:
  print(f"Failed to run {args.app_name} because runtime wasn't found in hip.config.yml")
  exit(1)
#getting the auth_backend_username
if hip_config['backend']['auth']['username']:
  authbackend_username=hip_config['backend']['auth']['username']
else:
  print(f"Failed to run {args.app_name} because authbackend username wasn't found in hip.config.yml")
  exit(1)
#getting the auth_backend_password
if hip_config['backend']['auth']['password']:
  authbackend_password=hip_config['backend']['auth']['password']
else:
  print(f"Failed to run {args.app_name} because authbackend password wasn't found in hip.config.yml")
  exit(1)
#getting the dockerfs type
if hip_config['base']['dockerfs']['type']:
  dockerfs_type=hip_config['base']['dockerfs']['type']
else:
  print(f"Failed to run {args.app_name} because dockerfs type wasn't found in hip.config.yml")
  exit(1)
#getting the dockerfs cert
if hip_config['base']['dockerfs']['type']:
  dockerfs_cert=hip_config['base']['dockerfs']['cert']
else:
  print(f"Failed to run {args.app_name} because dockerfs cert wasn't found in hip.config.yml")
  exit(1)

# get the user token or password
hip_password=None
if dockerfs_type == "ghostfs":
  query_params = urllib.parse.urlencode({
    "hipuser": args.hip_user,
    "gf": args.group_folders
  })
  r = requests.get(args.auth_backend_domain + '/token?' + query_params, auth=(authbackend_username, authbackend_password))
  if r.status_code != 200:
      print(f"Received invalid token for user {args.hip_user}: {r}")
      exit(1)
  else:
      hip_password=r.json().get('token')
elif dockerfs_type == "davfs2":
  hip_password=args.hip_password
else:
  print(f"Failed to run {args.app_name} because an unsupported dockerfs_type was provided")
  exit(1)

#run app container
ret_val = subprocess.check_call(["docker", "run", "-d", \
                                                  "-v", f"{server_name}_x11-unix:/tmp/.X11-unix", \
                                                  f"--network={server_name}_apps", \
                                                  *(["--device=/dev/dri:/dev/dri"] if card != 'none' else []),
                                                  "--device=/dev/fuse:/dev/fuse", \
                                                  "--cap-add=SYS_ADMIN", \
                                                  "--security-opt", "apparmor=unconfined", \
                                                  "--runtime", runtime, \
                                                  "--ipc=host", \
                                                  "--name", container_name, \
                                                  "--hostname", container_name, \
                                                  "--restart", "on-failure:5", \
                                                  *(["--env-file", app_env_path] if os.path.exists(app_env_path) else []),
                                                  "--env", "NVIDIA_VISIBLE_DEVICES=all", \
                                                  "--env", "NVIDIA_DRIVER_CAPABILITIES=all", \
                                                  "--env", "DISPLAY=:80", \
                                                  "--env", f"HIP_USER={args.hip_user}", \
                                                  "--env", f"HIP_PASSWORD={hip_password}", \
                                                  "--env", f"NEXTCLOUD_DOMAIN={args.nextcloud_domain}", \
                                                  "--env", f"DOCKERFS_TYPE={dockerfs_type}", \
                                                  "--env", f"DOCKERFS_CERT={dockerfs_cert}", \
                                                  "--env", f"CARD={card}", \
                                                  "--env", f"APP_NAME={args.app_name}", \
                                                  f"{ci_registry_image}/{args.app_name}:{app_version}{tag}"])
assert ret_val == 0, f"Failed running {args.app_name}."
