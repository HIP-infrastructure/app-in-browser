#!/usr/bin/env python3

import argparse
import os
import subprocess
from shutil import copy2

import yaml


parser = argparse.ArgumentParser()
parser.add_argument(
    "--base-images", action="store_true", help="Build only the base images"
)
parser.add_argument("--server", action="store_true",
                    help="Build only the Xpra server")
parser.add_argument("--apps", action="store_true", help="Build only the apps")
parser.add_argument(
    "--apps-scope",
    help="A from-to list of apps, e.g. 'a-m'. Alternatively 'a' for all apps starting with a",
)
parser.add_argument("--dry-run", action="store_true", help="No doing anything")
parser.add_argument("-f", "--force", default=False, action=argparse.BooleanOptionalAction,
                    help="overwrite images already found in the registry")

def build_base_images(images, force):
    for base, params in images.items():
        if params["state"]:
            if force:
                ret_val = subprocess.check_call(
                    ["./scripts/buildbaseimage.py --force", base])
            else:
                ret_val = subprocess.check_call(
                ["./scripts/buildbaseimage.py", base])
            assert ret_val == 0, f"Failed building {params['name']}."
        else:
            print(
                f"Skipping {params['name']} because it is in state 'off'."
            )


def build_server(force):
    if force:
        ret_val = subprocess.call("./scripts/buildserver.py --force")
    else:
        ret_val = subprocess.call("./scripts/buildserver.py")
    assert ret_val == 0, "Failed building server."


def build_apps(apps, force):
    for app, params in apps.items():
        if params["state"]:
            if force:
                ret_val = subprocess.check_call(["./scripts/buildapp.py --force", app])
            else:
                ret_val = subprocess.check_call(["./scripts/buildapp.py", app])
            assert ret_val == 0, f"Failed building {params['name']}."
        else:
            print(
                f"Skipping {params['name']} because it is in state 'off'."
            )


def main():
    with open("hip.yml", encoding="utf-8") as f:
        hip = yaml.load(f, Loader=yaml.FullLoader)
        # print(hip)

    # copy hip.config.yml from template if it does not exist
    if not os.path.isfile("hip.config.yml"):
        copy2("hip.config.template.yml", "hip.config.yml")

    # Allow to run only specific parts of the lengthy build process.
    args = parser.parse_args()
    has_base_images = args.base_images or (not args.server and not args.apps)
    has_server = args.server or (not args.base_images and not args.apps)
    has_apps = args.apps or (not args.base_images and not args.server)

    base_list = hip["base"]
    app_list = hip["apps"]

    # Filter out some apps
    scope = args.apps_scope
    if scope:
        scope = scope.lower()

        # No ranges means one application will be built.
        if "-" in scope:
            start, stop = scope.split("-", 2)
        else:
            start, stop = scope, scope

        # Keep the items that are greater of equal to the scope
        # and smaller or equal to the stop scope ignoring the extra character to include them all.
        # Such that "z" includes all the keys starting with z.
        app_list = {
            k: v
            for k, v in app_list.items()
            if k != "" and start <= k and k[0: len(stop)] <= stop
        }

    if args.dry_run:
        print("Building...")
        if has_base_images:
            print(f"base images: {', '.join(base_list)}")
        if has_server:
            print("Xpra server")
        if has_apps:
            print(f"apps: {', '.join(app_list)}")
        return

    if has_base_images:
        build_base_images(base_list, args.force)

    if has_server:
        build_server(args.force)

    if has_apps:
        build_apps(app_list, args.force)


if __name__ == "__main__":
    main()
