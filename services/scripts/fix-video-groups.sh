#!/bin/bash

# ensure that the user passed in parameter is part of vglusers groups
# which must have been set for /dev/dri/card0 and /dev/dri/renderD128

CARD=$1

if [ $CARD != "none" ]; then
  HIP_USER=$2

  echo -n "Adding user $HIP_USER into the right video groups... "

  DRI_CARD_GROUP_NAME=$(ls -l /dev/dri/card* | head -1 | awk '{print $4}')
  DRI_CARD_GID=$(ls -ln /dev/dri/card* | head -1 | awk '{print $4}')
  groupadd -f -g $DRI_CARD_GID $DRI_CARD_GROUP_NAME

  DRI_RENDER_GROUP_NAME=$(ls -l /dev/dri/render* | head -1 | awk '{print $4}')
  DRI_RENDER_GID=$(ls -ln /dev/dri/render* | head -1 | awk '{print $4}')
  groupadd -f -g $DRI_RENDER_GID $DRI_RENDER_GROUP_NAME

  usermod --groups $DRI_CARD_GID,$DRI_RENDER_GID --append $HIP_USER

  echo "done."
fi
