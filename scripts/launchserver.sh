#!/bin/bash

SERVER_ID=$1
HIP_USER=$2
NAME=${SERVER_ID}-${HIP_USER}

#source .env
set -o allexport; source .env; set +o allexport

#create volume
docker volume create ${NAME}_x11-unix

#create network
docker network create -d bridge ${NAME}_server

#run container
docker run \
  -p "127.0.0.1::8080" \
  -v ${NAME}_x11-unix:/tmp/.X11-unix \
  --device=/dev/dri:/dev/dri \
  --runtime	${RUNTIME} \
  --name xpra-server-${NAME} \
  --hostname xpra-server-${NAME} \
  --restart unless-stopped \
  --env-file .env \
  --env NVIDIA_VISIBLE_DEVICES=all \
  --env NVIDIA_DRIVER_CAPABILITIES=all \
  xpra-server
