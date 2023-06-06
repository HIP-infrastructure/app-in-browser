#!/bin/bash

./scripts/restrictnetwork.sh
if [ $? -eq 1 ]; then
  echo "Failed to restrict network."
  exit 1
fi

./scripts/downloadall.py
if [ $? -eq 1 ]; then
  echo "Failed to download docker images."
  exit 1
fi

./scripts/installbackend.sh
if [ $? -eq 1 ]; then
  echo "Failed to install backend."
  exit 1
fi
