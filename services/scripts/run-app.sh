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

if [ $APP_NAME == "slicer" ]; then
  #case when there is no data in APP_DATA_DIR beforehand
  NC_APP_DATA_DIR=/home/$HIP_USER/nextcloud/app_data/slicer/slicer.org
  APP_DATA_DIR=/apps/slicer/install/Slicer/slicer.org
  mkdir -p ${NC_APP_DATA_DIR}
  ln -s ${NC_APP_DATA_DIR} ${APP_DATA_DIR}
  chown -R $HIP_USER:$HIP_USER ${APP_DATA_DIR}
elif [ $APP_NAME == "localizer" ] || [ $APP_NAME == "bidsalyzer" ]; then
  #case when there is data in APP_DATA_DIR beforehand
  NC_APP_DATA_DIR=/home/$HIP_USER/nextcloud/app_data/$APP_NAME/Resources
  APP_DATA_DIR=/apps/$APP_NAME/install/${APP_NAME^}.${APP_VERSION}.linux64/Resources
  if [ ! -d ${NC_APP_DATA_DIR} ]; then
    mkdir -p ${NC_APP_DATA_DIR}
    cp -a ${APP_DATA_DIR}/* ${NC_APP_DATA_DIR}
  fi
  rm -rf ${APP_DATA_DIR}
  ln -s ${NC_APP_DATA_DIR} ${APP_DATA_DIR}
  chown -R $HIP_USER:$HIP_USER ${APP_DATA_DIR}
elif [ $APP_NAME == "matlab" ] || [ $APP_NAME == "brainstorm_matlab" ] ||[ $APP_NAME == "intranat" ]; then
  #case when APP_NAME needs a matlab license
  echo -e $MATLAB_LICENSE | sed -e 's/^"//' -e 's/"$//' > /opt/matlab/R2023a/licenses
elif [ $APP_NAME == "ciclone" ]; then
  NC_APP_DATA_DIR=/home/$HIP_USER/nextcloud/app_data/ciclone/config
  APP_DATA_DIR=/apps/$APP_NAME/venv/lib/python3.10/site-packages/$APP_NAME/config
  echo "APP_DATA_DIR: $APP_DATA_DIR"

  # Ensure the NC_APP_DATA_DIR exists
  if [ ! -d "${NC_APP_DATA_DIR}" ]; then
    mkdir -p "${NC_APP_DATA_DIR}"
    # Copy files only if the source directory exists
    if [ -d "${APP_DATA_DIR}" ]; then
      cp -a "${APP_DATA_DIR}/"* "${NC_APP_DATA_DIR}"
    else
      echo "Warning: Source directory ${APP_DATA_DIR} does not exist."
    fi
  fi
  # Remove the existing APP_DATA_DIR and create a symbolic link
  rm -rf "${APP_DATA_DIR}"
  ln -s "${NC_APP_DATA_DIR}" "${APP_DATA_DIR}"
  # Set ownership and permissions
  chown -R $HIP_USER:$HIP_USER "${APP_DATA_DIR}"
  APP_CMD_PREFIX="export PATH=/apps/$APP_NAME/venv/bin/:$PATH"
elif [ $APP_NAME == "bidssearchtool" ]; then
  NC_CONFIG_DIR=/home/$HIP_USER/nextcloud/app_data/bidssearchtool/config
  CONFIG_DIR=/usr/local/lib/python3.10/dist-packages/src
  NC_PARQUET_DIR=/home/$HIP_USER/nextcloud/app_data/bidssearchtool/parquet_files
  PARQUET_DIR=/apps/${APP_NAME}/BIDS-Search-Tool/data/parquet_files
  if [ ! -d ${NC_CONFIG_DIR} ]; then
    mkdir -p ${NC_CONFIG_DIR}
    cp ${CONFIG_DIR}/user_config.yaml ${NC_CONFIG_DIR}
  fi
  rm -f ${CONFIG_DIR}/user_config.yaml
  ln -s ${NC_CONFIG_DIR}/user_config.yaml ${CONFIG_DIR}/user_config.yaml
  if [ ! -d ${NC_PARQUET_DIR} ]; then
    mkdir -p ${NC_PARQUET_DIR}
  fi
  rm -rf ${PARQUET_DIR}
  ln -s ${NC_PARQUET_DIR} ${PARQUET_DIR}
  chown -R $HIP_USER:$HIP_USER ${PARQUET_DIR}
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
