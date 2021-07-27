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

#run container
docker run \
  -d \
  -v ${SERVER_NAME}_x11-unix:/tmp/.X11-unix \
  --network=${SERVER_NAME}_server \
  --device=/dev/dri:/dev/dri \
  --device=/dev/fuse:/dev/fuse \
  --cap-add=SYS_ADMIN \
  --security-opt apparmor=unconfined \
  --runtime ${RUNTIME} \
  --name ${CONTAINER_NAME} \
  --hostname ${CONTAINER_NAME} \
  --restart on-failure \
  --env-file .env \
  --env NVIDIA_VISIBLE_DEVICES=all \
  --env NVIDIA_DRIVER_CAPABILITIES=all \
  --env HIP_USER=${HIP_USER} \
  --env HIP_PASSWORD=${HIP_PASSWORD} \
  --env NEXTCLOUD_DOMAIN=${NEXTCLOUD_DOMAIN} \
  ${APP_NAME}

#connect to the server network
docker network connect ${SERVER_NAME}_apps ${CONTAINER_NAME}
