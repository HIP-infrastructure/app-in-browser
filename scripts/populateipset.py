#!/usr/bin/env python3

import yaml
import subprocess

#loading hip.config.yaml
with open('hip.config.yml') as f:
  hip_config = yaml.load(f, Loader=yaml.FullLoader)

#getting the backend whitelist
try:
  backend_whitelist=hip_config['backend']['whitelist']

  #populating the ipset with the backend whitelist
  for elem in backend_whitelist:
      print(f"Whitelisting {elem['comment']} with IP {elem['ip']}...")
      ret_val = subprocess.check_call(["sudo", "ipset", "add", "docker-allowed", \
                                     elem['ip'], "comment", elem['comment']])
except:
  print(f"Not whitelisting any backend IPs since no backend whitelist was found in hip.config.yml")

#getting the apps whitelist
try:
  apps_whitelist=hip_config['apps']['whitelist']

  #populating the ipset with the backend whitelist
  for app in apps_whitelist.values():
    for elem in app:
        print(f"Whitelisting {elem['comment']} with IP {elem['ip']}...")
        ret_val = subprocess.check_call(["sudo", "ipset", "add", "docker-allowed", \
                                       elem['ip'], "comment", elem['comment']])
except:
  print(f"Not whitelisting any apps IPs since no apps whitelist was found in hip.config.yml")
