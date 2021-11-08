#!/usr/bin/python3

import os
import subprocess
import argparse
import yaml
from dotenv import load_dotenv

# parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("name", help="name of the app to build")
parser.add_argument("version", help="version of the app to build")
args = parser.parse_args()

# load variables from .env
load_dotenv()
CI_REGISTRY_IMAGE = os.getenv('CI_REGISTRY_IMAGE')
CI_REGISTRY = os.getenv("CI_REGISTRY", "")

# define some needed variables
context = './services'
image = args.name + ":" + args.version
registry_image = CI_REGISTRY_IMAGE + '/' + image

# get version of dependencies
with open('hip.yml') as f:
  hip = yaml.load(f, Loader=yaml.FullLoader)
dcm2niix_version = hip['apps']['dcm2niix']['version']
anywave_version = hip['apps']['anywave']['version']

#pull app and cache from registry during CI only
if CI_REGISTRY:
  ret_val = subprocess.check_call(["docker", "pull", registry_image])
  assert ret_val == 0, "Failed pulling " + registry_image + " from registry."

#build app with cache from registry during CI only
ret_val = subprocess.check_call(["docker", "build", "--build-arg", "CI_REGISTRY_IMAGE=" + CI_REGISTRY_IMAGE, \
                                                    "--build-arg", "CI_REGISTRY=" + CI_REGISTRY, \
                                                    "--build-arg", "APP_NAME=" + args.name, \
                                                    "--build-arg", "APP_VERSION=" + args.version, \
                                                    "--build-arg", "DAVFS2_VERSION=" + os.getenv('DAVFS2_VERSION'), \
                                                    "--build-arg", "DCM2NIIX_VERSION=" + dcm2niix_version, \
                                                    "--build-arg", "ANYWAVE_VERSION=" + anywave_version, \
                                                    *(["--cache-from", registry_image] if os.getenv("CI_REGISTRY") else []),    
                                                    "-t", registry_image, \
                                                    "-f", context + "/apps/" + args.name + "/Dockerfile", \
                                                    context])
assert ret_val == 0, "Failed building " + args.name + "."

#push the app to registry during CI only
if CI_REGISTRY:
  ret_val = subprocess.check_call(["docker", "push", registry_image])
  assert ret_val == 0, "Failed pushing " + registry_image + " to registry."
  pass
