#!/usr/bin/env python3

import os
import sys
import subprocess
import argparse
from dotenv import dotenv_values
from common import get_ci_commit_branch, get_ci_registry, get_hip_image_list, get_tag, is_build_needed
from common import get_hip_config
from common import get_hip_image_version
from common import get_dockerfs_type
from common import get_dockerfs_version
from common import get_ci_registry_image

# parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("name", help="name of the app to build")
parser.add_argument("version", nargs="?", help="version of the app to build")
parser.add_argument("-f", "--force", default=False, action=argparse.BooleanOptionalAction,
                    help="overwrite images already found in the registry")
args = parser.parse_args()

name = args.name
version = args.version
image_type = "apps"

#loading hip.yaml
hip = get_hip_image_list()

#loading hip.config.yaml
hip_config = get_hip_config()

#if version is not defined get it from hip.yml
if not version:
  try:
    version = get_hip_image_version(hip, name, image_type)
  except KeyError:
    print(f"Failed to build {name} because it wasn't found in hip.yml")
    exit(1)

#getting the dockerfs type
try:
  dockerfs_type = get_dockerfs_type(hip_config, image_type)
except KeyError:
  print(f"Failed to build {name} because it wasn't found in hip.config.yml")
  exit(1)

#getting the dockerfs version
try:
  dockerfs_version = get_dockerfs_version(hip, name, image_type, dockerfs_type)
except:
  print(f"Failed to build {name} because it wasn't found in hip.yml")
  exit(1)

# get ci_registry from env (default is empty string)
ci_registry = get_ci_registry()

# get ci_registry_image from env or from hip.config.yml
try:
  ci_registry_image = get_ci_registry_image(hip_config)
except LookupError:
  print(f"Failed to build {name} because CI registry image wasn't found")
  exit(1)

# get ci_commit_branch from env or from hip.config.yml
try:
  ci_commit_branch = get_ci_commit_branch(hip_config)
except LookupError:
  print(f"Failed to build {name} because CI registry image wasn't found")
  exit(1)

# create a tag
tag = get_tag(ci_commit_branch)

# define some needed variables
context = "./services"
image = f"{name}:{version}{tag}"
registry_image = f"{ci_registry_image}/{image}"

# check if this specific image:version-tag already exists in the registry
if not is_build_needed(ci_registry_image, name, version, tag, args.force):
  sys.exit(0)

# get app specific build-args
app_env_path=f"{context}/apps/{name}/build.env"
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
dcm2niix_version = hip["apps"]["dcm2niix"]["version"]
anywave_version = hip["apps"]["anywave"]["version"]
freesurfer_version = hip["apps"]["freesurfer"]["version"]
fsl_version = hip["apps"]["fsl"]["version"]
brainvisa_version = hip["apps"]["brainvisa"]["version"]
jupyterlab_desktop_version = hip["base"]["jupyterlab-desktop"]["version"]
matlab_desktop_version = hip["base"]["matlab-desktop"]["version"]
terminal_version = hip["base"]["terminal"]["version"]
virtualgl_version = hip["base"]["virtualgl"]["version"]
ghostfs_version = hip["base"]["ghostfs"]["version"]

#build app with cache from registry during CI only
ret_val = subprocess.check_call(["docker", "build", "--build-arg", f"CI_REGISTRY_IMAGE={ci_registry_image}", \
                                                    "--build-arg", f"CI_REGISTRY={ci_registry}", \
                                                    "--build-arg", f"APP_NAME={name}", \
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
                                                    "-f", f"{context}/apps/{name}/Dockerfile", \
                                                    context])
assert ret_val == 0, f"Failed building {name}."

#push the app to registry during CI only
if ci_registry:
  ret_val = subprocess.check_call(["docker", "push", registry_image])
  assert ret_val == 0, f"Failed pushing {registry_image} to registry."
  pass
