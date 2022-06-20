#!/usr/bin/env python3

import os
import subprocess
import yaml
from shutil import copy2

with open('hip.yml') as f:
  hip = yaml.load(f, Loader=yaml.FullLoader)
  #print(hip)

# copy .env.template to .env if .env does not exist
if not os.path.isfile('.env'):
  copy2('.env.template', '.env')

# build base images
ret_val = subprocess.call("./scripts/buildbaseimages.sh")
assert ret_val == 0, "Failed building base images."

# build server
ret_val = subprocess.call("./scripts/buildserver.sh")
assert ret_val == 0, "Failed building server."

# build apps
app_list = hip['apps']
for app, params in app_list.items():
  if params['state']:
    ret_val = subprocess.check_call(["./scripts/buildapp.py", app, str(params['version'])])
    assert ret_val == 0, f"Failed building {params['name']}."
  else:
    print(f"Skipping {params['name']} because it is in state {params['state']}.")
