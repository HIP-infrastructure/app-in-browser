#!/bin/bash

HIP_USER=$1
APP_NAME=$2

echo -n "Creating user $HIP_USER... "

egrep "^$HIP_USER" /etc/passwd >/dev/null

if [ $? -eq 0 ]; then
  echo "$HIP_USER already exists."
  exit 0
else
  useradd --create-home --shell /bin/bash $HIP_USER --uid 1000
  if [ $? -eq 0 ]; then
    echo "done."
    if [ -d "/apps/$APP_NAME/run" ]; then
      echo -n "Giving permissions to $HIP_USER... "
      chown -R $1:1000 /apps/$2/run
      if [ $? -eq 0 ]; then
        echo "done."
        exit 0
      else
        echo "failed."
        exit 1
      fi
    fi
  else
    echo "failed."
    exit 1
  fi
fi
