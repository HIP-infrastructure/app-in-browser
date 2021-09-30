#!/usr/bin/python3

import yaml
import subprocess

with open('hip.yml') as f:
  hip = yaml.load(f, Loader=yaml.FullLoader)
  #print(hip)

# build base images
ret_val = subprocess.call("./scripts/buildbaseimages.sh")
assert ret_val == 0, "Failed building base images."

# build server
ret_val = subprocess.call("./scripts/buildserver.sh")
assert ret_val == 0, "Failed building server."

# build apps
app_list = hip['apps']
for app, params in app_list.items():
  if params['state'] == 'ready':
    ret_val = subprocess.check_call(["./scripts/buildapp.sh", app])
    assert ret_val == 0, "Failed building " + "params['name']" + "."
  else:
    print('Skipping ' + params['name'] + ' because it is ' + params['state'] + '.')
