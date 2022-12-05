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

#putting cert into file
mkdir -p /apps/ghostfs/secrets/
echo -e $DOCKERFS_CERT | sed -e 's/^"//' -e 's/"$//' > /apps/ghostfs/secrets/cert.pem

echo "done."

echo -n "Mounting ${NEXTCLOUD_DOMAIN} for ${HIP_USER} as ghostfs... "
#rm -f /var/run/mount.davfs/home-hipuser-nextcloud.pid

CMD="GhostFS --client --host $NEXTCLOUD_HOST --port $NEXTCLOUD_PORT --cert /apps/ghostfs/secrets/cert.pem -o big_writes -o large_read -o allow_root -o debug --write-back 0 --read-ahead 0 --user $HIP_USER --token $HIP_PASSWORD /home/$HIP_USER/nextcloud & echo \$! > /tmp/ghostfs_pid"
#CMD="GhostFS --client --host $NEXTCLOUD_HOST --port $NEXTCLOUD_PORT --cert /apps/ghostfs/secrets/cert.pem -o big_writes -o large_read -o allow_root --write-back 0 --read-ahead 0 --user $HIP_USER --token $HIP_PASSWORD /home/$HIP_USER/nextcloud & echo \$! > /tmp/ghostfs_pid"
runuser -l $HIP_USER -c "$CMD"

sleep 2

if ! ps -p $(cat /tmp/ghostfs_pid) > /dev/null
then
   echo "failed."
   exit 1
fi
echo "done."

exit 0
