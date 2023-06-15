#!/bin/bash

#export $APP_NAME specific environment variables to $HIP_USER .env file
while IFS='=' read -r -d '' k v; do
  if [[ "${k,,}" == ${APP_NAME}* ]]; then
    echo -n "Exporting ${k} for ${HIP_USER}... "
    echo "export ${k}=${v}" > /home/$HIP_USER/.env
    chown $HIP_USER:$HIP_USER /home/$HIP_USER/.env
    echo "done."
  fi
done < <(env -0)

if [ $APP_SPECIAL == "terminal" ]; then
  PROCESS_NAME="/usr/bin/wezterm"
  APP_NAME="wezterm"
  APP_CMD="/usr/bin/wezterm"
  mkdir -p /home/$HIP_USER/.config/wezterm
  cp /apps/$APP_SPECIAL/wezterm.lua /home/$HIP_USER/.config/wezterm
  chown $HIP_USER:$HIP_USER /home/$HIP_USER/.config
  chown -R $HIP_USER:$HIP_USER /home/$HIP_USER/.config/wezterm
  #CARD=none
elif [ $APP_SPECIAL == "jupyterlab-desktop" ]; then
  PROCESS_NAME="jlab"
  APP_NAME="jupyterlab-desktop"
  APP_CMD_PREFIX="export PATH=/apps/jupyterlab-desktop/conda/bin/:$PATH"
  APP_CMD="jlab"
fi

#fix slicer extension manager
if [ $APP_NAME == "slicer" ]; then
  mkdir -p /home/$HIP_USER/nextcloud/app_data/slicer/NA-MIC
  ln -s /home/$HIP_USER/nextcloud/app_data/slicer/NA-MIC /apps/slicer/install/Slicer/NA-MIC
  chown -R $HIP_USER:$HIP_USER /apps/slicer/install/Slicer/NA-MIC
fi

#add DISPLAY to APP_PREFIX
if [ ! -z "${APP_CMD_PREFIX}" ]; then
  APP_CMD_PREFIX="export DISPLAY=$DISPLAY;$APP_CMD_PREFIX"
else
  APP_CMD_PREFIX="export DISPLAY=$DISPLAY"
fi

#run $APP_NAME as $HIP_USER
echo -n "Running $APP_NAME as $HIP_USER "
if [ $CARD == "none" ]; then
  echo "on CPU... "
  #CMD="$APP_CMD_PREFIX; QT_DEBUG_PLUGINS=1 $APP_CMD"
  CMD="$APP_CMD_PREFIX; $APP_CMD"
else
  echo "on GPU... "
  #CMD="$APP_CMD_PREFIX; vglrun -d /dev/dri/$CARD /opt/VirtualGL/bin/glxspheres64"
  #CMD="$APP_CMD_PREFIX; QT_DEBUG_PLUGINS=1 vglrun -d /dev/dri/$CARD $APP_CMD"
  CMD="$APP_CMD_PREFIX; vglrun -d /dev/dri/$CARD $APP_CMD"
fi

runuser -l $HIP_USER -c "$CMD &"
#runuser -l $HIP_USER -c 'sleep 1000000000000'

#wait until $APP_NAME has terminated
sleep 3
#ps ax
PID=`ps ax | grep "$PROCESS_NAME" | grep -v $0 | awk '{print $1}' | tr '\n' ' ' | awk '{print $1}'`
ps -p $PID > /dev/null
retVal=$?
if [ $retVal -eq 0 ]; then
  tail --pid=$PID -f /dev/null
fi
echo "$APP_NAME exited."
