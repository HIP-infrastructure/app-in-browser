#!/usr/bin/env python3

import os
import yaml
import subprocess

#loading hip.yaml
with open('hip.yml') as f:
  hip = yaml.load(f, Loader=yaml.FullLoader)
#loading hip.config.yaml
with open('hip.config.yml') as f:
  hip_config = yaml.load(f, Loader=yaml.FullLoader)

#getting version
if hip['server']['xpra']['version']:
  xpra_version=hip['server']['xpra']['version']
else:
  print(f"Failed to build xpra-server because it wasn't found in hip.yml")
  exit(1)

# get version of dependencies
virtualgl_version = hip['base']['virtualgl']['version']

# load variables from env
ci_registry_image = os.getenv('CI_REGISTRY_IMAGE')
ci_registry = os.getenv("CI_REGISTRY", "")
ci_commit_branch = os.getenv('CI_COMMIT_BRANCH')

# get ci_registry_image from hip.config.yml in case it is not defined in env
if not ci_registry_image:
  if hip_config['backend']['ci']['registry']['image']:
    ci_registry_image=hip_config['backend']['ci']['registry']['image']
  else:
    print(f"Failed to build xpra-server because CI registry image wasn't found in hip.config.yml")
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
image = f"xpra-server:{xpra_version}{tag}"
registry_image = f"{ci_registry_image}/{image}"

#pull xpra-server and cache from registry during CI only
if ci_registry:
  try:
    subprocess.check_call(["docker", "pull", registry_image])
  except subprocess.CalledProcessError as e:
    print(f"Failed pulling {registry_image} from registry.")

#build xpra-server with cache from registry during CI only
subprocess.check_call(["docker", "buildx", "build", \
                                 "--build-arg", f"CI_REGISTRY_IMAGE={ci_registry_image}", \
                                 "--build-arg", f"XPRA_VERSION={xpra_version}", \
                                 "--build-arg", f"TAG={tag}", \
                                 "--build-arg", f"VIRTUALGL_VERSION={virtualgl_version}", \
                                 *(["--cache-from", registry_image] if ci_registry else []),
                                 *(["--progress=plain"] if ci_registry else []),
                                 "-t", registry_image, \
                                 "-f", f"{context}/server/Dockerfile.{xpra_version}", \
                                 context])

#push xpra-server to registry during CI only
if ci_registry:
  ret_val = subprocess.check_call(["docker", "push", registry_image])
  assert ret_val == 0, f"Failed pushing {registry_image} to registry."
  pass


if ci_commit_branch == 'dev' and ci_registry:
  context = './services/server/change-background'
  registry_image_background = registry_image + "-chorusbg"
  ret_val = subprocess.check_call(["docker", "build", "--build-arg", f"REGISTRY_IMAGE={registry_image}", \
                                                    *(["--cache-from", registry_image] if ci_registry else []),
                                                    *(["--progress=plain"] if ci_registry else []),
                                                    "-t", registry_image_background, \
                                                    "-f", f"{context}/Dockerfile", \
                                                    context])
  assert ret_val == 0, f"Failed building xpra-server."
  ret_val = subprocess.check_call(["docker", "push", registry_image_background])
  assert ret_val == 0, f"Failed pushing {registry_image_background} to registry."
  print(f"pushed {registry_image_background}")