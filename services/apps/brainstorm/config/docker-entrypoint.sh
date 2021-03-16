#!/bin/bash
# based on https://github.com/ffeldhaus/docker-xpra-html5-gpu-minimal/blob/master/docker-entrypoint.sh
/home/hip-user/scripts/check-dri.sh
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

# ensure that xpra user is part of vglusers group which must have been set for /dev/dri/card0
DRI_CARD_GROUP_NAME=$(ls -l /dev/dri/card* | head -1 | awk '{print $4}')
DRI_CARD_GID=$(ls -ln /dev/dri/card* | head -1 | awk '{print $4}')
groupadd -f -g $DRI_CARD_GID $DRI_CARD_GROUP_NAME
DRI_RENDER_GROUP_NAME=$(ls -l /dev/dri/render* | head -1 | awk '{print $4}')
DRI_RENDER_GID=$(ls -ln /dev/dri/render* | head -1 | awk '{print $4}')
groupadd -f -g $DRI_RENDER_GID $DRI_RENDER_GROUP_NAME
usermod --groups $DRI_CARD_GID,$DRI_RENDER_GID --append hip-user

#run brainstorm as hip-user
#CMD="DISPLAY=:80 vglrun -d /dev/dri/card1 /opt/VirtualGL/bin/glxspheres64"
CMD="DISPLAY=:80 vglrun -d /dev/dri/card1 /home/hip-user/apps/brainstorm/run/brainstorm3/bin/R2020a/brainstorm3.command /usr/local/MATLAB/MATLAB_Runtime/v98"
runuser -l hip-user -c "$CMD"
#runuser -l hip-user -c 'sleep 1000000000000'
