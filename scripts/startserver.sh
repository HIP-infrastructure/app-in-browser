#!/bin/bash

#source .env
set -o allexport; source .env; set +o allexport

SERVER_ID=$1
HIP_USER=$2
CONTAINER_NAME=${SERVER_ID}-${HIP_USER}

#create volume
docker volume create ${CONTAINER_NAME}_x11-unix

#check for MTU
if [ ! -z ${MTU} ]; then
  OPTS="--opt com.docker.network.driver.mtu=${MTU}"
fi

#create network
docker network create -d bridge ${CONTAINER_NAME}_server
docker network create --internal ${OPTS} ${CONTAINER_NAME}_apps

#check for GPU
if [ ${CARD} != "none" ]; then
  DEV="--device=/dev/dri:/dev/dri"
fi

#get a random free port
PORT=$(python3 -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')

#run container
docker run \
  -d \
  -p "127.0.0.1:${PORT}:8080" \
  -v ${CONTAINER_NAME}_x11-unix:/tmp/.X11-unix \
  -v /var/run/dbus:/var/run/dbus \
  --privileged \
  --network=${CONTAINER_NAME}_server \
  ${DEV} \
  --runtime	${RUNTIME} \
  --ipc="host" \
  --name xpra-server-${CONTAINER_NAME} \
  --hostname xpra-server-${CONTAINER_NAME} \
  --restart on-failure \
  --env-file .env \
  --env NVIDIA_VISIBLE_DEVICES=all \
  --env NVIDIA_DRIVER_CAPABILITIES=all \
  --env XPRA_KEYCLOAK_REDIRECT_URI=${XPRA_KEYCLOAK_REDIRECT_URI_BASE}${PORT} \
  ${CI_REGISTRY_IMAGE}/xpra-server:${XPRA_VERSION}
