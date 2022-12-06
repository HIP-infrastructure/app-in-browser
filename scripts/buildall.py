#!/usr/bin/env python3

import os
import subprocess
import yaml
from shutil import copy2

with open('hip.yml') as f:
  hip = yaml.load(f, Loader=yaml.FullLoader)
  #print(hip)

# copy hip.config.yml from template if it does not exist
if not os.path.isfile('hip.config.yml'):
  copy2('hip.config.template.yml', 'hip.config.yml')

# build base images
base_list = hip['base']
for base, params in base_list.items():
  if params['state']:
    ret_val = subprocess.check_call(["./scripts/buildbaseimage.py", base])
    assert ret_val == 0, f"Failed building {params['name']}."
  else:
    print(f"Skipping {params['name']} because it is in state {params['state']}.")

# build server
ret_val = subprocess.call("./scripts/buildserver.py")
assert ret_val == 0, "Failed building server."

# build apps
app_list = hip['apps']
for app, params in app_list.items():
  if params['state']:
    ret_val = subprocess.check_call(["./scripts/buildapp.py", app])
    assert ret_val == 0, f"Failed building {params['name']}."
  else:
    print(f"Skipping {params['name']} because it is in state {params['state']}.")
