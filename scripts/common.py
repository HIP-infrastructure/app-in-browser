#!/usr/bin/env python3
import yaml
import subprocess

def get_hip_image_list():
    with open("hip.yml") as f:
        hip = yaml.load(f, Loader=yaml.FullLoader)
    return hip

def get_hip_config():
    with open("hip.config.yml") as f:
        hip_config = yaml.load(f, Loader=yaml.FullLoader)
    return hip_config

def check_image_type(image_type):
    valid_image_type = {"apps", "base"}
    if image_type not in valid_image_type:
        raise ValueError(f"image_type must be one of {valid_image_type}")

def get_hip_image_version(image_list, image_name, image_type):
    check_image_type(image_type)
    version = image_list.get(image_type, {}).get(image_name, {}).get("version", "")
    if not version:
        raise KeyError()
    return version

def get_dockerfs_type(config, image_type):
    check_image_type(image_type)
    dockerfs_type = config.get(image_type, {}).get("dockerfs", {}).get("type", "")
    if not dockerfs_type:
       raise KeyError()
    return dockerfs_type

def get_dockerfs_version(config, image_type, dockerfs_type):
    check_image_type(image_type)
    dockerfs_version = config.get(image_type, {}).get(dockerfs_type, {}).get("version", "")
    if not dockerfs_version:
        raise KeyError()
    return dockerfs_version

def get_ci_registry_image(config):
  ci_registry_image = config.get("backend", {}).get("ci", {})\
                        .get("registry", {}).get("image", "")
  if not ci_registry_image:
      raise KeyError()
  return ci_registry_image

def get_ci_commit_branch(config):
    ci_commit_branch = config.get("backend", {}).get("ci", {})\
                        .get("commit_branch", "")
    if not ci_commit_branch:
        raise KeyError()
    return ci_commit_branch

def is_image_in_registry(registry_image):
    return (subprocess.run(["docker", "manifest", "inspect", registry_image],
                         capture_output=True).returncode == 0)
