#!/bin/bash

if [ $APP_SHELL == "yes" ]; then
  PROCESS_NAME="/opt/Hyper/hyper"
  APP_NAME="hyper"
  APP_CMD="hyper"
  CARD=none
fi

#run $APP_NAME as $HIP_USER
echo -n "Running $APP_NAME as $HIP_USER "
if [ $CARD == "none" ]; then
  echo "on CPU... "
  CMD="DISPLAY=$DISPLAY $APP_CMD"
else
  echo "on GPU... "
  #CMD="vglrun -d /dev/dri/$CARD /opt/VirtualGL/bin/glxspheres64"
  CMD="DISPLAY=$DISPLAY vglrun -d /dev/dri/$CARD $APP_CMD"
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
