#!/usr/bin/env python3

import os
import subprocess
import yaml
from shutil import copy2

with open('hip.yml') as f:
  hip = yaml.load(f, Loader=yaml.FullLoader)
with open('hip.config.yml') as f:
  hip_config = yaml.load(f, Loader=yaml.FullLoader)

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

#getting the registry
if hip_config['backend']['ci']['registry']['image']:
  ci_registry_image=hip_config['backend']['ci']['registry']['image']
else:
  print(f"Failed to run {args.app_name} because CI registry image wasn't found in hip.config.yml")
  exit(1)

#get login info for registry
if hip_config['backend']['ci']['registry']:
  registry_username=hip_config['backend']['ci']['registry']['username']
  registry_token=hip_config['backend']['ci']['registry']['token']
else:
  print(f"Failed to run {args.app_name} because registry info wasn't found in hip.config.yml")
  exit(1)

#login to registry
ret_val = subprocess.check_call(["docker", "login", ci_registry_image, \
                                                    "-u", registry_username, \
                                                    "-p", registry_token], stderr=subprocess.DEVNULL)
assert ret_val == 0, f"Failed running {args.app_name} because login to registry failed."

# download base images
base_list = hip['base']
for base, params in base_list.items():
  if params['state']:
    #getting the base image version
    if hip['base'][base]['version']:
      version=hip['base'][base]['version']
    else:
      print(f"Failed to download {base} because it wasn't found in hip.yml")
      exit(1)
    # loop over all versions
    if not isinstance(version, list):
      version = [version]
    for index, ver in enumerate(version):
      # special case for matlab-runtime
      if base == 'matlab-runtime':
        # get update
        update = hip['base']['matlab-runtime']['update'][index]
        image = f"{base}:{ver}_u{update}{tag}"
      else:
        image = f"{base}:{ver}{tag}"
      registry_image = f"{ci_registry_image}/{image}"
      #pulling the base image
      ret_val = subprocess.check_call(["docker", "pull", f"{registry_image}"])
      assert ret_val == 0, f"Failed pulling {base}."
  else:
    print(f"Skipping {params['name']} because it is in state {params['state']}.")

# download server
if hip['server']['xpra']['state']:
  #getting the server version
  if hip['server']['xpra']['version']:
    version=hip['server']['xpra']['version']
  else:
    print(f"Failed to download xpra-server because it wasn't found in hip.yml")
    exit(1)
  #pulling server
  ret_val = subprocess.check_call(["docker", "pull", f"{ci_registry_image}/xpra-server:{version}{tag}"])
  assert ret_val == 0, f"Failed pulling xpra-server."
else:
  print(f"Skipping {params['name']} because it is in state {params['state']}.")

# download apps
app_list = hip['apps']
for app, params in app_list.items():
  if params['state']:
    #getting app version
    if hip['apps'][app]['version']:
      version=hip['apps'][app]['version']
    else:
      print(f"Failed to download {app} because it wasn't found in hip.yml")
      exit(1)
    #pulling the app
    ret_val = subprocess.check_call(["docker", "pull", f"{ci_registry_image}/{app}:{version}{tag}"])
    assert ret_val == 0, f"Failed pulling {app}."
  else:
    print(f"Skipping {params['name']} because it is in state {params['state']}.")

#logout from registry
ret_val = subprocess.check_call(["docker", "logout", ci_registry_image])
assert ret_val == 0, f"Failed running {args.app_name} because logout from registry failed."
