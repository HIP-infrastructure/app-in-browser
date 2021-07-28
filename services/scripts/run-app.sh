#!/bin/bash

CARD=$1
HIP_USER=$2
APP=$3

#run $APP as $HIP_USER
echo -n "Running $APP as $HIP_USER "
if [ $CARD == "none" ]; then
  echo "on CPU... "
  CMD="DISPLAY=:80 $APP && /usr/sbin/umount.davfs /home/$HIP_USER/nextcloud"
else
  echo "on GPU... "
  #CMD="DISPLAY=:80 vglrun -d /dev/dri/$CARD /opt/VirtualGL/bin/glxspheres64"
  CMD="DISPLAY=:80 vglrun -d /dev/dri/$CARD $APP && /usr/sbin/umount.davfs /home/$HIP_USER/nextcloud"
fi
runuser -l $HIP_USER -c "$CMD"
#runuser -l $HIP_USER -c 'sleep 1000000000000'
