#!/bin/bash

SERVER_ID=$1
HIP_USER=$2
CONTAINER_NAME=xpra-server-${SERVER_ID}-${HIP_USER}

docker ps -a --no-trunc --filter name=${CONTAINER_NAME}
