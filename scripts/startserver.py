#!/usr/bin/env python3

import argparse
import yaml
import json
import subprocess
import os
import socket

# parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("server_id", help="server_id of the server to run the app on")
parser.add_argument("hip_user", help="nextcloud username of the hip user to run the app as")
parser.add_argument("auth_groups", help="groups allowed to use this server")
args = parser.parse_args()

container_name = f"{args.server_id}-{args.hip_user}"

# parsing auth_groups
auth_groups = " ".join(json.loads(args.auth_groups))

#loading hip.yaml
with open('hip.yml') as f:
  hip = yaml.load(f, Loader=yaml.FullLoader)
#loading hip_config.yaml
with open('hip.config.yml') as f:
  hip_config = yaml.load(f, Loader=yaml.FullLoader)
#getting the server version
if hip['server']['xpra']['version']:
  xpra_version=hip['server']['xpra']['version']
else:
  print(f"Failed to run the server because it wasn't found in hip.yml")
  exit(1)
#getting the tag
if hip_config['backend']['ci']['commit_branch']:
  ci_commit_branch=hip_config['backend']['ci']['commit_branch']
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
  print(f"Failed to load card it wasn't found in hip_config.yml")
  exit(1)
#getting the runtime
if hip_config['backend']['dri']['runtime']:
  runtime=hip_config['backend']['dri']['runtime']
else:
  print(f"Failed to load runtime it wasn't found in hip_config.yml")
  exit(1)
#getting keycloak settings
if hip_config['server']['keycloak']:
  auth=hip_config['server']['keycloak']['auth']
  server_url=hip_config['server']['keycloak']['server_url']
  realm_name=hip_config['server']['keycloak']['realm_name']
  client_id=hip_config['server']['keycloak']['client_id']
  client_secret=hip_config['server']['keycloak']['client_secret']
  redirect_uri_base=hip_config['server']['keycloak']['redirect_uri_base']
  scope=hip_config['server']['keycloak']['scope']
  groups_claim=hip_config['server']['keycloak']['groups_claim']
  auth_condition=hip_config['server']['keycloak']['auth_condition']
  grant_type=hip_config['server']['keycloak']['grant_type']
else:
  print(f"Failed to load runtime it wasn't found in hip_config.yml")
  exit(1)

# get ci_registry_image from hip.config.yml in case it is not defined in env
if hip_config['backend']['ci']['registry']['image']:
  ci_registry_image=hip_config['backend']['ci']['registry']['image']
else:
  print(f"Failed to run xpra-server because CI registry image wasn't found in hip.config.yml")
  exit(1)

#create volume
ret_val = subprocess.check_call(["docker", "volume", "create", f"{container_name}_x11-unix"])
assert ret_val == 0, f"Failed creating volume {container_name}_x11-unix."

#create network
ret_val = subprocess.check_call(["docker", "network", "create", "-d", "bridge", f"{container_name}_server"])
assert ret_val == 0, f"Failed creating network {container_name}_server."
ret_val = subprocess.check_call(["docker", "network", "create", "-d", "bridge", f"{container_name}_apps"])
assert ret_val == 0, f"Failed creating network {container_name}_apps."

#get a random free port
s=socket.socket()
s.bind(("", 0))
port=s.getsockname()[1]
s.close()

#run container
ret_val = subprocess.check_call(["docker", "run", "-d", \
                                                  "-p", f"{port}:8080", \
                                                  "-v", f"{container_name}_x11-unix:/tmp/.X11-unix", \
                                                  "-v", "/var/run/dbus:/var/run/dbus", \
                                                  "--privileged", \
                                                  f"--network={container_name}_server", \
                                                  *(["--device=/dev/dri:/dev/dri"] if card != 'none' else []),
                                                  "--runtime", runtime, \
                                                  "--ipc=host", \
                                                  "--name", f"xpra-server-{container_name}", \
                                                  "--hostname", f"xpra-server-{container_name}", \
                                                  "--restart", "on-failure:5",
                                                  "--env", "NVIDIA_VISIBLE_DEVICES=all", \
                                                  "--env", "NVIDIA_DRIVER_CAPABILITIES=all", \
                                                  "--env", f"CARD={card}", \
                                                  "--env", f"XPRA_KEYCLOAK_AUTH={auth}", \
                                                  "--env", f"XPRA_KEYCLOAK_SERVER_URL={server_url}", \
                                                  "--env", f"XPRA_KEYCLOAK_REALM_NAME={realm_name}", \
                                                  "--env", f"XPRA_KEYCLOAK_CLIENT_ID={client_id}", \
                                                  "--env", f"XPRA_KEYCLOAK_CLIENT_SECRET_KEY={client_secret}", \
                                                  "--env", f"XPRA_KEYCLOAK_REDIRECT_URI={redirect_uri_base}{port}", \
                                                  "--env", f"XPRA_KEYCLOAK_SCOPE=\"{scope}\"", \
                                                  "--env", f"XPRA_KEYCLOAK_GROUPS_CLAIM={groups_claim}", \
                                                  "--env", f"XPRA_KEYCLOAK_AUTH_GROUPS=\"{auth_groups}\"", \
                                                  "--env", f"XPRA_KEYCLOAK_AUTH_CONDITION={auth_condition}", \
                                                  "--env", f"XPRA_KEYCLOAK_GRANT_TYPE={grant_type}", \
                                                  "--env", "OAUTHLIB_INSECURE_TRANSPORT=1", \
                                                  f"{ci_registry_image}/xpra-server:{xpra_version}{tag}"])
assert ret_val == 0, f"Failed running xpra-server-${container_name}."
