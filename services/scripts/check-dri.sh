#!/bin/bash
if [ ! -d "/dev/dri" ];then
  echo "ERROR: Directory /dev/dri does not exists, likely the GPU is not available to container."
  exit 1
fi
  echo "SUCCESS: Directory /dev/dri exists, likely the GPU is available to container."
  exit 0
