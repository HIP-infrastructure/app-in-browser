#!/bin/bash

HIP_USER=$1
HIP_PASSWORD=$2
NEXTCLOUD_DOMAIN=$3
NEXTCLOUD_URL="${NEXTCLOUD_DOMAIN}/remote.php/dav/files/${HIP_USER}"

echo -n "Adding user $HIP_USER into the davfs2 group... "
usermod --groups davfs2 --append $HIP_USER
echo "done."

echo -n "Configuring davfs2... "
cd /home/$HIP_USER

mkdir -p /home/$HIP_USER/nextcloud
mkdir -p /home/$HIP_USER/.davfs2
echo "${NEXTCLOUD_URL} ${HIP_USER} \"${HIP_PASSWORD}\"" >> /etc/davfs2/secrets
unset HIP_PASSWORD
cp /etc/davfs2/secrets /home/$HIP_USER/.davfs2/secrets
chown -R $HIP_USER:davfs2 /home/$HIP_USER/nextcloud
chown -R $HIP_USER:davfs2 /home/$HIP_USER/.davfs2
chmod 600 /home/$HIP_USER/.davfs2/secrets 
echo "use_locks 0" >> /etc/davfs2/davfs2.conf
echo "${NEXTCLOUD_URL} /home/${HIP_USER}/nextcloud  davfs  user,rw,auto 0 0" > /etc/fstab
echo "done."

echo -n "Mounting ${NEXTCLOUD_DOMAIN} for ${HIP_USER} as webdav... "
rm -f /var/run/mount.davfs/home-hipuser-nextcloud.pid
mount /home/$HIP_USER/nextcloud
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "failed."
    exit $retVal
fi
echo "done."
exit 0
