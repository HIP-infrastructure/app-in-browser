#!/bin/bash

HIP_USER=$1
GHOSTFS="GhostFS"

#umount ghostfs share
echo "Umounting ghostfs share for $HIP_USER..."
PID=`ps ax |grep $GHOSTFS | grep -v grep | awk '{print $1}' | tr '\n' ' '`
kill -9 $PID
ps -p $PID > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo -n "done."
  exit 0
fi
echo -n "failed."
exit $retVal
