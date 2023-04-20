#!/usr/bin/env python3

import os
import subprocess
import argparse
import yaml

# parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("name", help="name of the base image to build")
parser.add_argument('version', nargs='?', help="version of the base image to build")
args = parser.parse_args()

name=args.name
version=args.version

#loading hip.yaml
with open('hip.yml') as f:
  hip = yaml.load(f, Loader=yaml.FullLoader)
#loading hip.config.yaml
with open('hip.config.yml') as f:
  hip_config = yaml.load(f, Loader=yaml.FullLoader)

#getting the dockerfs type
if name == 'dockerfs':
  if hip_config['base']['dockerfs']['type']:
    name = hip_config['base']['dockerfs']['type']
  else:
    print(f"Failed to run {name} because dockerfs type wasn't found in hip.config.yml")
    exit(1)

#if version is not defined get it from hip.yml
if not version:
  if hip['base'][name]['version']:
    version=hip['base'][name]['version']
  else:
    print(f"Failed to build {name} because it wasn't found in hip.yml")
    exit(1)

# load variables from env
ci_registry_image = os.getenv('CI_REGISTRY_IMAGE')
ci_registry = os.getenv('CI_REGISTRY', '')
ci_commit_branch = os.getenv('CI_COMMIT_BRANCH')

# get ci_registry_image from hip.config.yml in case it is not defined in env
if not ci_registry_image:
  if hip_config['backend']['ci']['registry']['image']:
    ci_registry_image=hip_config['backend']['ci']['registry']['image']
  else:
    print(f"Failed to build {name} because CI registry image wasn't found in hip.config.yml")
    exit(1)

# get ci_commit_branch from hip.config.yml in case it is not defined in env
if not ci_commit_branch:
  if hip_config['backend']['ci']['commit_branch']:
    ci_commit_branch=hip_config['backend']['ci']['commit_branch']
  else:
    print(f"Failed to build {name} because CI registry image wasn't found in hip.config.yml")
    exit(1)

# create a tag
if ci_commit_branch == "dev":
  tag = f"-{ci_commit_branch}"
else:
  tag = ''

# get version of dependencies
virtualgl_version = hip['base']['virtualgl']['version']
terminal_version = hip['base']['terminal']['version']
dockerfs_type = hip_config['base']['dockerfs']['type']
dockerfs_version = hip['base'][dockerfs_type]['version']

# loop over all versions
if not isinstance(version, list):
  version = [version]
for index, ver in enumerate(version):
  # define some needed variables
  context = './services'
  dockerfile = 'Dockerfile'
  update = ''
  # special case for matlab-runtime
  if name == 'matlab-runtime':
    # get update
    update = hip['base']['matlab-runtime']['update'][index]
    image = f"{name}:{ver}_u{update}{tag}"
    if (ver == 'R2015a' or ver == 'R2018b'):
      dockerfile = f"{dockerfile}.pre2019"
  else:
    image = f"{name}:{ver}{tag}"
  registry_image = f"{ci_registry_image}/{image}"

  #pull base image and cache from registry during CI only
  if ci_registry:
    try:
      ret_val = subprocess.check_call(["docker", "pull", registry_image])
    except subprocess.CalledProcessError as e:
      print(f"Failed pulling {registry_image} from registry.")

  #build base image with cache from registry during CI only
  ret_val = subprocess.check_call(["docker", "build", "--build-arg", f"CI_REGISTRY_IMAGE={ci_registry_image}", \
                                                      "--build-arg", f"VERSION={ver}", \
                                                      "--build-arg", f"UPDATE={update}", \
                                                      "--build-arg", f"TAG={tag}", \
                                                      "--build-arg", f"VIRTUALGL_VERSION={virtualgl_version}", \
                                                      "--build-arg", f"TERMINAL_VERSION={terminal_version}", \
                                                      "--build-arg", f"DOCKERFS_VERSION={dockerfs_version}", \
                                                      "--build-arg", f"DOCKERFS_TYPE={dockerfs_type}", \
                                                      *(["--cache-from", registry_image] if ci_registry else []),
                                                      *(["--progress=plain"] if ci_registry else []),
                                                      "-t", registry_image, \
                                                      "-f", f"{context}/base-images/{name}/{dockerfile}", \
                                                      context])
  assert ret_val == 0, f"Failed building {name}."

  #push the base image to registry during CI only
  if ci_registry:
    ret_val = subprocess.check_call(["docker", "push", registry_image])
    assert ret_val == 0, f"Failed pushing {registry_image} to registry."
    pass
