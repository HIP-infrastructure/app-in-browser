#!/bin/bash

SCRIPT_PATH=/apps/brainstorm/scripts

$SCRIPT_PATH/check-dri.sh $CARD
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

$SCRIPT_PATH/create-user.sh $HIP_USER brainstorm
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

#old way without nextcloud
#ln -sf /apps/brainstorm/run/brainstorm_db /home/$HIP_USER
#chown -R $HIP_USER:1000 /home/$HIP_USER/brainstorm_db

#symlink app_data directories in $HIP_USER homedir
DIR_ARRAY=( "brainstorm/brainstorm_db" "brainstorm/.brainstorm" )
#DIR_ARRAY=( "brainstorm/brainstorm_db" "brainstorm/.brainstorm" "brainstorm/.mcrCache9.8" )
$SCRIPT_PATH/homedir-symlink.sh $HIP_USER ${DIR_ARRAY[@]}
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#run brainstorm as $HIP_USER
echo -n "Running brainstorm as $HIP_USER "
if [ $CARD == "none" ]; then
  echo "on CPU... "
  CMD="DISPLAY=:80 /apps/brainstorm/install/brainstorm3/bin/R2020a/brainstorm3.command /usr/local/MATLAB/MATLAB_Runtime/v98 && /usr/sbin/umount.davfs /home/$HIP_USER/nextcloud"
else
  echo "on GPU... "
  #CMD="DISPLAY=:80 vglrun -d /dev/dri/$CARD /opt/VirtualGL/bin/glxspheres64"
  CMD="DISPLAY=:80 vglrun -d /dev/dri/$CARD /apps/brainstorm/install/brainstorm3/bin/R2020a/brainstorm3.command /usr/local/MATLAB/MATLAB_Runtime/v98 && /usr/sbin/umount.davfs /home/$HIP_USER/nextcloud"
fi
runuser -l $HIP_USER -c "$CMD"
#runuser -l $HIP_USER -c 'sleep 1000000000000'
