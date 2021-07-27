#!/bin/bash

#source .env
set -o allexport; source .env; set +o allexport

SERVER_ID=$1
HIP_USER=$2
CONTAINER_NAME=${SERVER_ID}-${HIP_USER}

#create volume
docker volume create ${CONTAINER_NAME}_x11-unix

#create network
docker network create -d bridge ${CONTAINER_NAME}_server
docker network create --internal --opt com.docker.network.driver.mtu=${MTU} ${CONTAINER_NAME}_apps

#run container
docker run \
  -d \
  -p "127.0.0.1::8080" \
  -v ${CONTAINER_NAME}_x11-unix:/tmp/.X11-unix \
  --network=${CONTAINER_NAME}_server \
  --device=/dev/dri:/dev/dri \
  --runtime	${RUNTIME} \
  --name xpra-server-${CONTAINER_NAME} \
  --hostname xpra-server-${CONTAINER_NAME} \
  --restart on-failure \
  --env-file .env \
  --env NVIDIA_VISIBLE_DEVICES=all \
  --env NVIDIA_DRIVER_CAPABILITIES=all \
  xpra-server
