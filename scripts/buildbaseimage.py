#!/usr/bin/env python3

import os
import subprocess
import argparse
from common import get_ci_commit_branch, get_ci_registry_image, get_hip_image_list
from common import get_hip_config
from common import get_hip_image_version
from common import get_dockerfs_type
from common import get_dockerfs_version
import sys

# parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("name", help="name of the base image to build")
parser.add_argument('version', nargs='?', help="version of the base image to build")
parser.add_argument("-f", "--force", default=False, action=argparse.BooleanOptionalAction,
                    help="overwrite images already found in the registry")
args = parser.parse_args()

name = args.name
version = args.version
image_type = "base"

#loading hip.yaml
hip = get_hip_image_list()

#loading hip.config.yaml
hip_config = get_hip_config()

#if version is not defined get it from hip.yml
if not version:
  try:
    version = get_hip_image_version(hip, name, image_type)
  except ValueError:
    print(f"Failed to build {name} because it wasn't found in hip.yml")
    exit(1)

dockerfs_type = ""
dockerfs_version = ""
if name == 'dockerfs':
  #getting the dockerfs type
  try:
    dockerfs_type = get_dockerfs_type(hip_config, image_type)
  except ValueError:
    print(f"Failed to build {name} because it wasn't found in hip.config.yml")
    exit(1)

  #getting the dockerfs version
  try:
    dockerfs_version = get_dockerfs_version(hip, image_type, dockerfs_type)
  except:
    print(f"Failed to build {name} because it wasn't found in hip.yml")
    exit(1)

# load variables from env
ci_registry_image = os.getenv('CI_REGISTRY_IMAGE')
ci_registry = os.getenv('CI_REGISTRY', '')
ci_commit_branch = os.getenv('CI_COMMIT_BRANCH')

# get ci_registry_image from hip.config.yml in case it is not defined in env
if not ci_registry_image:
  try:
    ci_registry_image = get_ci_registry_image(hip_config)
  except:
    print(f"Failed to build {name} because CI registry image wasn't found in hip.config.yml")
    exit(1)

# get ci_commit_branch from hip.config.yml in case it is not defined in env
if not ci_commit_branch:
  try:
    ci_commit_branch = get_ci_commit_branch(hip_config)
  except:
    print(f"Failed to build {name} because CI registry image wasn't found in hip.config.yml")
    exit(1)

# create a tag
if ci_commit_branch != "master":
  tag = f"-{ci_commit_branch}"
else:
  tag = ''

# get version of dependencies
virtualgl_version = hip.get(image_type, {}).get("virtualgl", {})\
                      .get("version", "")
if not virtualgl_version:
    raise KeyError()
terminal_version = hip.get(image_type, {}).get("terminal", {})\
                      .get("version", "")
if not terminal_version:
    raise KeyError()

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

  # check if this specific image:version-tag already exists in the registry
  is_image_in_registry = is_image_in_registry(registry_image)

  if is_image_in_registry and not args.force:
    print(f"{image} skipped, already found in registry \n \
          Use 'force' to overwrite existing images")
    sys.exit(0)
  elif is_image_in_registry and args.force:
     print(f"Overwriting {image} found on the registry ('force' option used)")

  #pull base image and cache from registry during CI only
  if ci_registry:
    try:
      ret_val = subprocess.check_call(["docker", "pull", registry_image])
    except subprocess.CalledProcessError as e:
      print(f"Failed pulling {registry_image} from registry.")

  #build base image with cache from registry during CI only
  subprocess.check_call(["docker", "buildx", "build", \
                                   "--build-arg", f"CI_REGISTRY_IMAGE={ci_registry_image}", \
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

  #push the base image to registry during CI only
  if ci_registry:
    ret_val = subprocess.check_call(["docker", "push", registry_image])
    assert ret_val == 0, f"Failed pushing {registry_image} to registry."
    pass
