#!/bin/bash
# script to test if the process with name passed in parameter is running
PID=`ps ax |grep $1 | grep -v $0 | awk '{print $1}' | tr '\n' ' '`
ps -p $PID > /dev/null 
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "$1 is not running."
  exit $retVal
fi
echo "$1 is running."
exit 0
