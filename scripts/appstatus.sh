#!/bin/bash

APP_NAME=$1
SERVER_ID=$2
APP_ID=$3
HIP_USER=$4
CONTAINER_NAME=${APP_NAME}-${SERVER_ID}-${APP_ID}-${HIP_USER}

docker ps -a --no-trunc --filter name=${CONTAINER_NAME}
