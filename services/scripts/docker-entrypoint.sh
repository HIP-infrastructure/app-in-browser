#!/bin/bash

SCRIPT_PATH=/apps/$APP_NAME/scripts

$SCRIPT_PATH/check-dri.sh $CARD
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

$SCRIPT_PATH/create-user.sh $HIP_USER $APP_NAME
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

#mount davfs2 share for $HIP_USER
$SCRIPT_PATH/mount-davfs2.sh $HIP_USER $HIP_PASSWORD $NEXTCLOUD_DOMAIN
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#symlink app_data directories in $HIP_USER homedir
$SCRIPT_PATH/homedir-symlink.sh $HIP_USER ${DIR_ARRAY[@]}
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#run $APP_NAME as $HIP_USER
$SCRIPT_PATH/run-app.sh 
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#umount davfs2 share for $HIP_USER
$SCRIPT_PATH/umount-davfs2.sh $HIP_USER
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi
