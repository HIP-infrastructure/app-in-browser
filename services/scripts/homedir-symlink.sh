#!/bin/bash

HIP_USER=$1; shift
DIR_ARRAY=( "$@" )

#symlink all directories of $DIR_ARRAY in $HIP_USER homedir

for DIR in "${DIR_ARRAY[@]}"; do
  if [[ ! -d /home/$HIP_USER/nextcloud/app_data/$APP_NAME/$DIR ]]; then
    echo -n "Creating distant directory $DIR... "
    # creating distant directory and applying the right ownership since it does not exist
    mkdir -p /home/$HIP_USER/nextcloud/app_data/$APP_NAME/$DIR
    chown -R $HIP_USER:davfs2 /home/$HIP_USER/nextcloud/app_data/$APP_NAME/$DIR
    echo "done."
  fi

  LOCAL_PATH=$(dirname $DIR)
  if [[ "$LOCAL_PATH" == "." ]]; then
    # we can use $DIR directly since it's not a subdirectory
    LOCAL_PATH=$DIR
  else
    if [[ ! -d /home/$HIP_USER/$LOCAL_PATH ]]; then
    echo -n "Creating local directory $LOCAL_PATH... "
    # creating local directory and applying the right ownsership since it does not exist
    mkdir -p /home/$HIP_USER/$LOCAL_PATH
    chown -R $HIP_USER:davfs2 /home/$HIP_USER/$LOCAL_PATH
    echo "done."
    fi
  fi

  # symlinking
  echo -n "Symlinking $DIR from davfs2... "
  ln -sf /home/$HIP_USER/nextcloud/app_data/$APP_NAME/$DIR /home/$HIP_USER/$DIR
  retVal=$?
  if [ $retVal -ne 0 ]; then
    exit $retVal
  fi
  # applying the right ownership to the symlink
  chown -R $HIP_USER:davfs2 /home/$HIP_USER/$DIR
  echo "done."
done
