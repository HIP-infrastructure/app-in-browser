#!/bin/bash
# based on https://github.com/ffeldhaus/docker-xpra-html5-gpu-minimal/blob/master/docker-entrypoint.sh

SCRIPT_PATH=/apps/brainstorm/scripts

$SCRIPT_PATH/check-dri.sh
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

$SCRIPT_PATH/fix-video-groups.sh $HIP_USER
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

$SCRIPT_PATH/mount-davfs2.sh $HIP_USER $HIP_PASSWORD $NEXTCLOUD_DOMAIN
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#symlink brainstorm_db in $HIP_USER homedir
ln -sf /apps/brainstorm/run/brainstorm_db /home/$HIP_USER
chown -R $HIP_USER:1000 /home/$HIP_USER/brainstorm_db

#run brainstorm as $HIP_USER
#CMD="DISPLAY=:80 vglrun -d /dev/dri/$CARD /opt/VirtualGL/bin/glxspheres64"
CMD="DISPLAY=:80 vglrun -d /dev/dri/$CARD /apps/brainstorm/install/brainstorm3/bin/R2020a/brainstorm3.command /usr/local/MATLAB/MATLAB_Runtime/v98"
runuser -l $HIP_USER -c "$CMD"
#runuser -l $HIP_USER -c 'sleep 1000000000000'
