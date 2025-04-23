#!/usr/bin/env python3

import argparse
import subprocess
import sys

from scripts.common import get_ci_commit_branch, get_ci_registry, get_ci_registry_image, get_hip_config, get_hip_image_list, get_hip_image_version, get_tag, is_build_needed

# parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("name", default="xpra", help="name of the server to build")
parser.add_argument("version", nargs="?", help="version of the app to build")
parser.add_argument("-f", "--force", default=False, action=argparse.BooleanOptionalAction,
                    help="overwrite images already found in the registry")
args = parser.parse_args()

name = args.name
version = args.version
image_type = "server"

#loading hip.yaml
hip = get_hip_image_list()

#loading hip.config.yaml
hip_config = get_hip_config()

#getting version
if not version:
  try:
    version = get_hip_image_version(hip, name, image_type)
  except KeyError:
    print(f"Failed to build {name} because it wasn't found in hip.yml")
    exit(1)

# get version of dependencies
virtualgl_version = hip.get("base", {}).get("virtualgl", {})\
                      .get("version", "")
if not virtualgl_version:
    raise KeyError()

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
# note that the image name pattern is
# different compared to the apps and the base
# image names
context = './services'
image = f"{name}-{image_type}:{version}{tag}"
registry_image = f"{ci_registry_image}/{image}"

# check if this specific image:version-tag already exists in the registry
if not is_build_needed(ci_registry_image, f"{name}-{image_type}", version, tag, args.force):
  sys.exit(0)

#pull xpra-server and cache from registry during CI only
if ci_registry:
  try:
    subprocess.check_call(["docker", "pull", registry_image])
  except subprocess.CalledProcessError as e:
    print(f"Failed pulling {registry_image} from registry.")

#build xpra-server with cache from registry during CI only
subprocess.check_call(["docker", "buildx", "build", \
                                 "--build-arg", f"CI_REGISTRY_IMAGE={ci_registry_image}", \
                                 "--build-arg", f"XPRA_VERSION={version}", \
                                 "--build-arg", f"TAG={tag}", \
                                 "--build-arg", f"VIRTUALGL_VERSION={virtualgl_version}", \
                                 *(["--cache-from", registry_image] if ci_registry else []),
                                 *(["--progress=plain"] if ci_registry else []),
                                 "-t", registry_image, \
                                 "-f", f"{context}/server/Dockerfile.{version}", \
                                 context])

#push xpra-server to registry during CI only
if ci_registry:
  ret_val = subprocess.check_call(["docker", "push", registry_image])
  assert ret_val == 0, f"Failed pushing {registry_image} to registry."
  pass
