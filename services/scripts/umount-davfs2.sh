#!/bin/bash

HIP_USER=$1

#umount webdav share
echo "Umounting webdav share for $HIP_USER..."
CMD="/usr/sbin/umount.davfs /home/$HIP_USER/nextcloud"
runuser -l $HIP_USER -c "$CMD"
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retVal
fi
exit 0
