#!/usr/bin/env python3

import os
import subprocess
import argparse
import yaml
from dotenv import dotenv_values

# parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("name", help="name of the app to build")
parser.add_argument('version', nargs='?', help="version of the app to build")
args = parser.parse_args()

version=args.version

#loading hip.yaml
with open('hip.yml') as f:
  hip = yaml.load(f, Loader=yaml.FullLoader)
#loading hip.config.yaml
with open('hip.config.yml') as f:
  hip_config = yaml.load(f, Loader=yaml.FullLoader)

#if version is not defined get it from hip.yml
if not version:
  if hip['apps'][args.name]['version']:
    version=hip['apps'][args.name]['version']
  else:
    print(f"Failed to build {args.name} because it wasn't found in hip.yml")
    exit(1)

#getting the dockerfs type
if hip_config['base']['dockerfs']['type']:
  dockerfs_type=hip_config['base']['dockerfs']['type']
else:
  print(f"Failed to build {args.name} because dockerfs type wasn't found in hip.config.yml")
  exit(1)
#getting the dockerfs version
if hip['base'][dockerfs_type]['version']:
  dockerfs_version=hip['base'][dockerfs_type]['version']
else:
  print(f"Failed to build {args.name} because dockerfs version wasn't found in hip.yml")
  exit(1)

# load variables from env
ci_registry_image = os.getenv('CI_REGISTRY_IMAGE')
ci_registry = os.getenv("CI_REGISTRY", "")
ci_commit_branch = os.getenv('CI_COMMIT_BRANCH')

# get ci_registry_image from hip.config.yml in case it is not defined in env
if not ci_registry_image:
  if hip_config['backend']['ci']['registry']['image']:
    ci_registry_image=hip_config['backend']['ci']['registry']['image']
  else:
    print(f"Failed to build {args.name} because CI registry image wasn't found in hip.config.yml")
    exit(1)

# get ci_commit_branch from hip.config.yml in case it is not defined in env
if not ci_commit_branch:
  if hip_config['backend']['ci']['commit_branch']:
    ci_commit_branch=hip_config['backend']['ci']['commit_branch']
  else:
    print(f"Failed to build {name} because CI registry image wasn't found in hip.config.yml")
    exit(1)

# create a tag
if ci_commit_branch != "master":
  tag = f"-{ci_commit_branch}"
else:
  tag = ''

# define some needed variables
context = './services'
image = f"{args.name}:{version}{tag}"
registry_image = f"{ci_registry_image}/{image}"

# get app specific build-args
app_env_path=f"{context}/apps/{args.name}/build.env"
app_env=[]
if os.path.exists(app_env_path):
  config = dotenv_values(app_env_path)
  app_env = [i for k, v in config.items() for i in ["--build-arg", f"{k}={v}"]]

#pull app and cache from registry during CI only
if ci_registry:
  try:
    ret_val = subprocess.check_call(["docker", "pull", registry_image])
  except subprocess.CalledProcessError as e:
    print(f"Failed pulling {registry_image} from registry.")

# get version of dependencies
dcm2niix_version = hip['apps']['dcm2niix']['version']
anywave_version = hip['apps']['anywave']['version']
freesurfer_version = hip['apps']['freesurfer']['version']
fsl_version = hip['apps']['fsl']['version']
brainvisa_version = hip['apps']['brainvisa']['version']
jupyterlab_desktop_version = hip['base']['jupyterlab-desktop']['version']
matlab_desktop_version = hip['base']['matlab-desktop']['version']
terminal_version = hip['base']['terminal']['version']
virtualgl_version = hip['base']['virtualgl']['version']
ghostfs_version = hip['base']['ghostfs']['version']

#build app with cache from registry during CI only
ret_val = subprocess.check_call(["docker", "build", "--build-arg", f"CI_REGISTRY_IMAGE={ci_registry_image}", \
                                                    "--build-arg", f"CI_REGISTRY={ci_registry}", \
                                                    "--build-arg", f"APP_NAME={args.name}", \
                                                    "--build-arg", f"APP_VERSION={version}", \
                                                    "--build-arg", f"TAG={tag}", \
                                                    "--build-arg", f"DOCKERFS_TYPE={dockerfs_type}", \
                                                    "--build-arg", f"DOCKERFS_VERSION={dockerfs_version}", \
                                                    "--build-arg", f"JUPYTERLAB_DESKTOP_VERSION={jupyterlab_desktop_version}", \
                                                    "--build-arg", f"DCM2NIIX_VERSION={dcm2niix_version}", \
                                                    "--build-arg", f"ANYWAVE_VERSION={anywave_version}", \
                                                    "--build-arg", f"FREESURFER_VERSION={freesurfer_version}", \
                                                    "--build-arg", f"FSL_VERSION={fsl_version}", \
                                                    "--build-arg", f"BRAINVISA_VERSION={brainvisa_version}", \
                                                    "--build-arg", f"MATLAB_VERSION={matlab_desktop_version}", \
                                                    "--build-arg", f"TERMINAL_VERSION={terminal_version}", \
                                                    "--build-arg", f"VIRTUALGL_VERSION={virtualgl_version}", \
                                                    "--build-arg", f"GHOSTFS_VERSION={ghostfs_version}", \
                                                    *app_env,
                                                    *(["--cache-from", registry_image] if ci_registry else []),
                                                    *(["--progress=plain"] if ci_registry else []),
                                                    "-t", registry_image, \
                                                    "-f", f"{context}/apps/{args.name}/Dockerfile", \
                                                    context])
assert ret_val == 0, f"Failed building {args.name}."

#push the app to registry during CI only
if ci_registry:
  ret_val = subprocess.check_call(["docker", "push", registry_image])
  assert ret_val == 0, f"Failed pushing {registry_image} to registry."
  pass
