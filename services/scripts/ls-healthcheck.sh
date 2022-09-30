#!/bin/bash
# script to test if the directory with path passed in parameter exists and is not empty

if [[ -d $1 && -n "$(ls -A1 $1|grep -v app_data)" ]]; then 
  echo -n "docker-fs mounted properly in $1. "
  exit 0
else
  echo -n "docker-fs not mounted properly in $1. "
  exit 1
fi
