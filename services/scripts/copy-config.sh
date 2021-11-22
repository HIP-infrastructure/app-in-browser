#!/bin/bash

HIP_USER=$1; shift
CONFIG_ARRAY=( "$@" )

#copy all configuration files in $CONFIG_ARRAY in $HIP_USER homedir

for CONFIG in "${CONFIG_ARRAY[@]}"; do
  echo -n "Copying ${CONFIG} to ${HIP_USER} homedir... "
  cp -r /apps/${APP_NAME}/config/${CONFIG} /home/${HIP_USER}
  chown -R ${HIP_USER}:${HIP_USER} /home/${HIP_USER}/${CONFIG}
  echo "done."
done
