#!/usr/bin/env python3
import yaml
import subprocess
import sys
import os

def get_hip_image_list():
    with open("hip.yml") as f:
        hip = yaml.load(f, Loader=yaml.FullLoader)
    return hip

def get_hip_config():
    with open("hip.config.yml") as f:
        hip_config = yaml.load(f, Loader=yaml.FullLoader)
    return hip_config

def check_image_type(image_type):
    valid_image_type = {"apps", "base", "server"}
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

def get_ci_registry():
    return os.getenv("CI_REGISTRY", "")

def get_ci_registry_image(config):
    ci_registry_image = os.getenv('CI_REGISTRY_IMAGE')
    if not ci_registry_image:
        ci_registry_image = config.get("backend", {}).get("ci", {})\
                                .get("registry", {}).get("image", "")
        if not ci_registry_image:
            raise LookupError()
    return ci_registry_image

def get_ci_commit_branch(config):
    ci_commit_branch = os.getenv("CI_COMMIT_BRANCH")
    if not ci_commit_branch:
        ci_commit_branch = config.get("backend", {}).get("ci", {})\
                            .get("commit_branch", "")
        if not ci_commit_branch:
            raise LookupError()
    return ci_commit_branch

def is_build_needed(ci_registry_image, image_name, version, tag, force):
    image = f"{image_name}:{version}{tag}"
    registry_image = f"{ci_registry_image}/{image}"

    is_image_in_registry = bool(subprocess.run(["docker", "manifest", "inspect", registry_image],
                         capture_output=True).returncode == 0)
    is_version_latest = bool(version == "latest")

    if (is_image_in_registry
        and not is_version_latest
        and not force):
        print(f"{image} skipped, already found in registry \n \
                Use '--force' to overwrite existing images")
        return False
    elif is_image_in_registry and force:
        print(f"Overwriting {image} found on the registry ('force' option used)")
    elif is_image_in_registry and is_version_latest:
        print(f"Overwriting {image} found on the registry ('latest' version used)")
    return True

def get_tag(ci_commit_branch):
    tag = ""
    if ci_commit_branch != "master":
        tag = f"-{ci_commit_branch}"
    return tag