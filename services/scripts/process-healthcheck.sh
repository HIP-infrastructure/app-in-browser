#!/bin/bash
# script to test if $PROCESS_NAME is running

if [ $APP_SPECIAL == "terminal" ]; then
  PROCESS_NAME="/usr/bin/wezterm"
  APP_NAME="wezterm"
  APP_CMD="/usr/bin/wezterm"
elif [ $APP_SPECIAL == "jupyterlab-desktop" ]; then
  PROCESS_NAME="electron"
  APP_NAME="jupyterlab-desktop"
  APP_CMD="/apps/jupyterlab-desktop/node_modules/electron/dist/electron --no-sandbox /apps/jupyterlab-desktop"
fi

PID=`ps ax |grep $PROCESS_NAME | grep -v $0 | awk '{print $1}' | tr '\n' ' '`
ps -p $PID > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo -n "$APP_NAME is not running. "
  exit $retVal
fi
echo -n "$APP_NAME is running. "
exit 0
