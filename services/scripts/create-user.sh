#!/bin/bash

HIP_USER=$1

echo -n "Creating user $HIP_USER... "

egrep "^$HIP_USER" /etc/passwd >/dev/null

if [ $? -eq 0 ]; then
  echo "$HIP_USER already exists."
  exit 0
else
  useradd --create-home --shell /bin/bash $HIP_USER --uid 1000
  if [ $? -eq 0 ]; then
    echo "done."
    echo -n "Giving permissions to $HIP_USER... "
    chown -R $1:1000 /apps/$2/run
    if [ $? -eq 0 ]; then
      echo "done."
      exit 0
    else
      echo "failed."
      exit 1
    fi
  else
    echo "failed."
    exit 1
  fi
fi
