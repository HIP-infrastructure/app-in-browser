#!/bin/bash

SERVER_ID=$1
HIP_USER=$2
CONTAINER_NAME=xpra-server-${SERVER_ID}-${HIP_USER}

docker rm ${CONTAINER_NAME}

docker network rm ${SERVER_ID}-${HIP_USER}_server
docker network rm ${SERVER_ID}-${HIP_USER}_apps

docker volume rm ${SERVER_ID}-${HIP_USER}_x11-unix
