#!/bin/bash
# script to test if $PROCESS_NAME is running

if [ $APP_SHELL == "yes" ]; then
  PROCESS_NAME="/opt/Hyper/hyper"
  APP_NAME="hyper"
  CARD=none
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
