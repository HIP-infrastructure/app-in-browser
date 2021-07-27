#!/bin/bash

APP_NAME=$1
SERVER_ID=$2
APP_ID=$3
HIP_USER=$4
CONTAINER_NAME=${APP_NAME}-${SERVER_ID}-${APP_ID}-${HIP_USER}

docker inspect --format "{{json .State.Health }}" ${CONTAINER_NAME} | jq '.Log[].Output' | tail -1
