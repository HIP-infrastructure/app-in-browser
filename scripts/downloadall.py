#!/usr/bin/env python3

import subprocess

import yaml

with open("hip.yml") as f:
  hip = yaml.load(f, Loader=yaml.FullLoader)

with open("hip.config.yml") as f:
  hip_config = yaml.load(f, Loader=yaml.FullLoader)

# getting the tag
if not hip_config["backend"]["ci"]["commit_branch"]:
  print("Failed to load tag as it wasn't found in hip.config.yml")
  exit(1)

ci_commit_branch = hip_config["backend"]["ci"]["commit_branch"]
if ci_commit_branch == "dev":
  tag = f"-{ci_commit_branch}"
else:
  tag = ""

# getting the registry
if not hip_config["backend"]["ci"]["registry"]["image"]:
  print("Failed to run because CI registry image wasn't found in hip.config.yml")
  exit(1)

ci_registry_image = hip_config["backend"]["ci"]["registry"]["image"]

# get login info for registry
if not hip_config["backend"]["ci"]["registry"]:
  print("Failed to run because registry info wasn't found in hip.config.yml")
  exit(1)

registry_username = hip_config["backend"]["ci"]["registry"].get("username")
registry_token = hip_config["backend"]["ci"]["registry"].get("token")

"""
# login to registry (The registry is public so we comment it out)
if registry_username and registry_token:
  subprocess.check_call(
    [
      "docker",
      "login",
      ci_registry_image,
      "-u",
      registry_username,
      "-p",
      registry_token,
    ],
    stderr=subprocess.DEVNULL,
  )
"""
## download base images
# base_list = hip['base']
# for base, params in base_list.items():
#  if params['state']:
#    #getting the base image version
#    if hip['base'][base]['version']:
#      version=hip['base'][base]['version']
#    else:
#      print(f"Failed to download {base} because it wasn't found in hip.yml")
#      exit(1)
#    # loop over all versions
#    if not isinstance(version, list):
#      version = [version]
#    for index, ver in enumerate(version):
#      # special case for matlab-runtime
#      if base == 'matlab-runtime':
#        # get update
#        update = hip['base']['matlab-runtime']['update'][index]
#        image = f"{base}:{ver}_u{update}{tag}"
#      else:
#        image = f"{base}:{ver}{tag}"
#      registry_image = f"{ci_registry_image}/{image}"
#      #pulling the base image
#      ret_val = subprocess.check_call(["docker", "pull", f"{registry_image}"])
#      assert ret_val == 0, f"Failed pulling {base}."
#  else:
#    print(f"Skipping {params['name']} because it is in state {params['state']}.")

# download server
server_state = hip["server"]["xpra"]["state"]
if server_state:
  # getting the server version
  if not hip["server"]["xpra"]["version"]:
    print("Failed to download xpra-server because it wasn't found in hip.yml")
    exit(1)

  version = hip["server"]["xpra"]["version"]

  # pulling server
  subprocess.check_call(
    ["docker", "pull", f"{ci_registry_image}/xpra-server:{version}{tag}"]
  )
else:
  print(f"Skipping Xpra server because it is in state {server_state}.")

# download apps
app_list = hip["apps"]
for app, params in app_list.items():
  if not params["state"]:
    print(f"Skipping {params['name']} because it is in state {params['state']}.")
    continue

  # getting app version
  if not hip["apps"][app]["version"]:
    print(f"Failed to download {app} because it wasn't found in hip.yml")
    exit(1)

  version = hip["apps"][app]["version"]

  # pulling the app
  subprocess.check_call(["docker", "pull", f"{ci_registry_image}/{app}:{version}{tag}"])

# logout from registry
if registry_username and registry_token:
  subprocess.check_call(["docker", "logout", ci_registry_image])
