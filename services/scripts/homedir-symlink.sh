#!/bin/bash

HIP_USER=$1
HIP_GROUP=$2
TARGET_DIR=$3; shift; shift; shift
DIR_ARRAY=( "$@" )

#symlink all directories of $DIR_ARRAY in $HIP_USER homedir

for DIR in "${DIR_ARRAY[@]}"; do
  if [[ ! -d /home/$HIP_USER/nextcloud/$TARGET_DIR/$APP_NAME/$DIR ]]; then
    echo -n "Creating distant directory $DIR as $TARGET_DIR... "
    # creating distant directory and applying the right ownership since it does not exist
    mkdir -p /home/$HIP_USER/nextcloud/$TARGET_DIR/$APP_NAME/$DIR
    if [ "$DOCKERFS_TYPE" = "davfs2" ]; then
      chown -R $HIP_USER:$HIP_GROUP /home/$HIP_USER/nextcloud/$TARGET_DIR/$APP_NAME/$DIR
    fi
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
    chown -R $HIP_USER:$HIP_GROUP /home/$HIP_USER/$LOCAL_PATH
    echo "done."
    fi
  fi

  if [[ ! -L /home/$HIP_USER/$DIR ]]; then
    # symlinking
    echo -n "Symlinking $DIR as $TARGET_DIR via $DOCKERFS... "
    ln -sf /home/$HIP_USER/nextcloud/$TARGET_DIR/$APP_NAME/$DIR /home/$HIP_USER/$DIR
    retVal=$?
    if [ $retVal -ne 0 ]; then
      echo "failed."
      exit $retVal
    else
      echo "done."
    fi
  fi

  # applying the right ownership to the symlink
  echo -n "Applying correct permissions to $DIR... "
  chown -R $HIP_USER:$HIP_GROUP /home/$HIP_USER/$DIR
  retVal=$?
  if [ $retVal -ne 0 ]; then
    echo "failed."
    exit $retVal
  else
    echo "done."
  fi
done
