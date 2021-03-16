#!/bin/bash
# based on https://github.com/ffeldhaus/docker-xpra-html5-gpu-minimal/blob/master/docker-entrypoint.sh
./scripts/check-dri.sh
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
usermod --groups $DRI_CARD_GID,$DRI_RENDER_GID --append xpra
chmod -R 1777 /tmp/.X11-unix/
rm -rf /tmp/.X80-lock

# start xpra as xpra user with command specified in dockerfile as CMD or passed as parameter to docker run
#CMD="XPRA_PASSWORD=$XPRA_PASSWORD /usr/bin/xpra start --daemon=no --start-child='$@'"
runuser -l xpra -c 'xpra start :80 --bind-tcp=0.0.0.0:8080 --html=on --no-daemon --start="xhost +"'
#runuser -l xpra -c 'sleep 1000000000000'
