#!/bin/bash

HIP_USER=$1
HIP_PASSWORD=$2
NEXTCLOUD_DOMAIN=$3

NEXTCLOUD_HOST="${NEXTCLOUD_DOMAIN%:*}"
NEXTCLOUD_PORT="${NEXTCLOUD_DOMAIN##*:}"

echo -n "Configuring ghostfs... "
cd /home/$HIP_USER

mkdir -p /home/$HIP_USER/nextcloud
chown -R $HIP_USER:$HIP_USER /home/$HIP_USER/nextcloud
echo "user_allow_other" >> /etc/fuse.conf

echo "done."

echo -n "Mounting ${NEXTCLOUD_DOMAIN} for ${HIP_USER} as ghostfs... "
#rm -f /var/run/mount.davfs/home-hipuser-nextcloud.pid

CMD="GhostFS --client --host $NEXTCLOUD_HOST --port $NEXTCLOUD_PORT --cert /apps/ghostfs/secrets/cert.pem -o big_writes -o large_read -o allow_root --write-back 32 --read-ahead 0 --user $HIP_USER --token $HIP_PASSWORD /home/$HIP_USER/nextcloud &"
#CMD="GhostFS --client --host $NEXTCLOUD_HOST --port $NEXTCLOUD_PORT -o big_writes -o large_read -o allow_root --write-back 32 --read-ahead 32 --user $HIP_USER --token $HIP_PASSWORD /home/$HIP_USER/nextcloud &"
runuser -l $HIP_USER -c "$CMD"

retVal=$?
if [ $retVal -ne 0 ]; then
    echo "failed."
    exit $retVal
fi
echo "done."

sleep 2

exit 0
