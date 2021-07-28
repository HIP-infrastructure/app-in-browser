#!/bin/bash

SCRIPT_PATH=/apps/anywave/scripts

$SCRIPT_PATH/check-dri.sh $CARD
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

$SCRIPT_PATH/create-user.sh $HIP_USER anywave
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "return value is $retVal"
  exit $retVal
fi

$SCRIPT_PATH/fix-video-groups.sh $CARD $HIP_USER
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

$SCRIPT_PATH/mount-davfs2.sh $HIP_USER $HIP_PASSWORD $NEXTCLOUD_DOMAIN
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#symlink app_data directories in $HIP_USER homedir
DIR_ARRAY=( "anywave/AnyWave" )
$SCRIPT_PATH/homedir-symlink.sh $HIP_USER ${DIR_ARRAY[@]}
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#run anywave as $HIP_USER
APP="anywave"
$SCRIPT_PATH/run-app.sh $CARD $HIP_USER "$APP"
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi
