#!/bin/bash

HIP_USER=$1; shift
DIR_ARRAY=( "$@" )

#symlink all directories of $DIR_ARRAY in $HIP_USER homedir
#directory paths must be relative to app_data within the nextcloud dir

for DIR in "${DIR_ARRAY[@]}"; do
  echo -n "Symlinking $DIR from davfs2... "
  mkdir -p /home/$HIP_USER/nextcloud/app_data/$DIR
  chown -R $HIP_USER:davfs2 /home/$HIP_USER/nextcloud/app_data/$DIR
  ln -sf /home/$HIP_USER/nextcloud/app_data/$DIR /home/$HIP_USER
  retVal=$?
  if [ $retVal -ne 0 ]; then
    exit $retVal
  fi
  chown -R $HIP_USER:davfs2 /home/$HIP_USER/$(basename $DIR)
  echo "done."
done
