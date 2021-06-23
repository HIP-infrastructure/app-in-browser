#!/bin/bash

SCRIPT_PATH=/apps/template/scripts

$SCRIPT_PATH/check-dri.sh $CARD
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

$SCRIPT_PATH/create-user.sh $HIP_USER template
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

#symlink template_dir in $HIP_USER homedir
echo -n "Symlinking template from davfs2... "
mkdir -p /home/$HIP_USER/nextcloud/app_data/template/template_dir
chown -R $HIP_USER:davfs2 /home/$HIP_USER/nextcloud/app_data/template/template_dir
ln -sf /home/$HIP_USER/nextcloud/app_data/template/template_dir /home/$HIP_USER
if [ $retVal -ne 0 ]; then
  exit $retVal
fi
chown -R $HIP_USER:davfs2 /home/$HIP_USER/template_dir
echo "done."

#run template as $HIP_USER
echo -n "Running template as $HIP_USER... "
if [ $CARD == "none" ]; then
  echo "on CPU... "
  CMD="DISPLAY=:80 /apps/template/install/template.sh && /usr/sbin/umount.davfs /home/$HIP_USER/nextcloud"
else
  echo "on GPU... "
  CMD="DISPLAY=:80 vglrun -d /dev/dri/$CARD /apps/template/install/template.sh && /usr/sbin/umount.davfs /home/$HIP_USER/nextcloud"
fi
runuser -l $HIP_USER -c "$CMD"
