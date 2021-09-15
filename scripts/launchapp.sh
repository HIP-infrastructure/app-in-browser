#!/bin/bash

#source .env
set -o allexport; source .env; set +o allexport

APP_NAME=$1
SERVER_ID=$2
APP_ID=$3
HIP_USER=$4
HIP_PASSWORD=$5
NEXTCLOUD_DOMAIN=$6
CONTAINER_NAME=${APP_NAME}-${SERVER_ID}-${APP_ID}-${HIP_USER}
SERVER_NAME=${SERVER_ID}-${HIP_USER}
APP_VERSION=${APP_NAME^^}_VERSION

if [ -z ${!APP_VERSION} ]; then
  APP_VERSION=latest
else
  APP_VERSION=${!APP_VERSION}
fi

#check for GPU
if [ ${CARD} != "none" ]; then
  DEV="--device=/dev/dri:/dev/dri"
fi

#run container
docker run \
  -d \
  -v ${SERVER_NAME}_x11-unix:/tmp/.X11-unix \
  --network=${SERVER_NAME}_server \
  ${DEV} \
  --device=/dev/fuse:/dev/fuse \
  --cap-add=SYS_ADMIN \
  --security-opt apparmor=unconfined \
  --runtime ${RUNTIME} \
  --ipc="host" \
  --name ${CONTAINER_NAME} \
  --hostname ${CONTAINER_NAME} \
  --restart on-failure \
  --env-file .env \
  --env NVIDIA_VISIBLE_DEVICES=all \
  --env NVIDIA_DRIVER_CAPABILITIES=all \
  --env DISPLAY=:80 \
  --env HIP_USER=${HIP_USER} \
  --env HIP_PASSWORD=${HIP_PASSWORD} \
  --env NEXTCLOUD_DOMAIN=${NEXTCLOUD_DOMAIN} \
  --env APP_NAME=${APP_NAME} \
  --add-host releases.hyper.is:127.0.0.1 \
  --add-host releases-canary.hyper.is:127.0.0.1 \
  ${CI_REGISTRY_IMAGE}/${APP_NAME}:${APP_VERSION}

#connect to the server network
docker network connect ${SERVER_NAME}_apps ${CONTAINER_NAME}
