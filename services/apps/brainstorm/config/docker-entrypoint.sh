#!/bin/bash
# based on https://github.com/ffeldhaus/docker-xpra-html5-gpu-minimal/blob/master/docker-entrypoint.sh

HIP_USER=hip-user
SCRIPT_PATH=/home/$HIP_USER/scripts

$SCRIPT_PATH/check-dri.sh
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

$SCRIPT_PATH/fix-video-groups.sh $HIP_USER
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#run brainstorm as $HIP_USER
#CMD="DISPLAY=:80 vglrun -d /dev/dri/card1 /opt/VirtualGL/bin/glxspheres64"
CMD="DISPLAY=:80 vglrun -d /dev/dri/card1 /home/$HIP_USER/apps/brainstorm/run/brainstorm3/bin/R2020a/brainstorm3.command /usr/local/MATLAB/MATLAB_Runtime/v98"
runuser -l $HIP_USER -c "$CMD"
#runuser -l $HIP_USER -c 'sleep 1000000000000'
