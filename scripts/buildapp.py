#!/usr/bin/env python3

import os
import subprocess
import argparse
import yaml
from dotenv import load_dotenv, dotenv_values
from functools import reduce

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
image = f"{args.name}:{args.version}"
registry_image = f"{CI_REGISTRY_IMAGE}/{image}"

# get app specific build-args
context="./services"
app_env_path=f"{context}/apps/{args.name}/build.env"
app_env=[]
if os.path.exists(app_env_path):
  config = dotenv_values(app_env_path)
  app_env = [i for k, v in config.items() for i in ["--build-arg", f"{k}={v}"]]

# get version of dependencies
with open('hip.yml') as f:
  hip = yaml.load(f, Loader=yaml.FullLoader)
dcm2niix_version = hip['apps']['dcm2niix']['version']
anywave_version = hip['apps']['anywave']['version']

#pull app and cache from registry during CI only
if CI_REGISTRY:
  try:
    ret_val = subprocess.check_call(["docker", "pull", registry_image])
  except subprocess.CalledProcessError as e:
    print(f"Failed pulling {registry_image} from registry.")

#build app with cache from registry during CI only
ret_val = subprocess.check_call(["docker", "build", "--build-arg", f"CI_REGISTRY_IMAGE={CI_REGISTRY_IMAGE}", \
                                                    "--build-arg", f"CI_REGISTRY={CI_REGISTRY}", \
                                                    "--build-arg", f"APP_NAME={args.name}", \
                                                    "--build-arg", f"APP_VERSION={args.version}", \
                                                    "--build-arg", f"DAVFS2_VERSION={os.getenv('DAVFS2_VERSION')}", \
                                                    "--build-arg", f"JUPYTERLAB_DESKTOP_VERSION={os.getenv('JUPYTERLAB_DESKTOP_VERSION')}", \
                                                    "--build-arg", f"DCM2NIIX_VERSION={dcm2niix_version}", \
                                                    "--build-arg", f"ANYWAVE_VERSION={anywave_version}", \
                                                    *app_env,
                                                    *(["--cache-from", registry_image] if os.getenv("CI_REGISTRY") else []),
                                                    "-t", registry_image, \
                                                    "-f", f"{context}/apps/{args.name}/Dockerfile", \
                                                    context])
assert ret_val == 0, f"Failed building {args.name}."

#push the app to registry during CI only
if CI_REGISTRY:
  ret_val = subprocess.check_call(["docker", "push", registry_image])
  assert ret_val == 0, f"Failed pushing {registry_image} to registry."
  pass
