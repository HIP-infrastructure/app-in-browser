#!/usr/bin/env python3

import argparse
import yaml
import subprocess
import os
import socket

# parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("server_id", help="server_id of the server to run the app on")
parser.add_argument("hip_user", help="nextcloud username of the hip user to run the app as")
args = parser.parse_args()

container_name = f"{args.server_id}-{args.hip_user}"

#loading hip.yaml
with open('hip.yml') as f:
  hip = yaml.load(f, Loader=yaml.FullLoader)
#loading hip_config.yaml
with open('hip.config.yml') as f:
  hip_config = yaml.load(f, Loader=yaml.FullLoader)
#getting the server version
if hip['server']['xpra']:
  xpra_version=hip['server']['xpra']['version']
else:
  print(f"Failed to run the server because it wasn't found in hip.yml")
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
  grant_type=hip_config['server']['keycloak']['grant_type']
else:
  print(f"Failed to load runtime it wasn't found in hip_config.yml")
  exit(1)

# load variables from env
ci_registry_image = os.getenv('CI_REGISTRY_IMAGE')

# get ci_registry_image from hip.config.yml in case it is not defined in env
if not ci_registry_image:
  if hip_config['backend']['CI']['registry_image']:
    ci_registry_image=hip_config['backend']['CI']['registry_image']
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
                                                  "-p", f"127.0.0.1:{port}:8080", \
                                                  "-v", f"{container_name}_x11-unix:/tmp/.X11-unix", \
                                                  "-v", "/var/run/dbus:/var/run/dbus", \
                                                  "--privileged", \
                                                  f"--network={container_name}_server", \
                                                  *(["--device=/dev/dri:/dev/dri"] if card != 'none' else []),
                                                  "--runtime", runtime, \
                                                  "--ipc=host", \
                                                  "--name", f"xpra-server-{container_name}", \
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
                                                  "--env", f"XPRA_KEYCLOAK_GRANT_TYPE={grant_type}", \
                                                  f"{ci_registry_image}/xpra-server:{xpra_version}"])
assert ret_val == 0, f"Failed running xpra-server-${container_name}."
