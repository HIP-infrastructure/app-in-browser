#!/bin/bash

#source .env
set -o allexport; source .env; set +o allexport

CONTEXT="./services"
IMAGE="xpra-server:latest"

#build xpra-server
docker build \
  --build-arg VIRTUALGL_VERSION=${VIRTUALGL_VERSION} \
  -t ${IMAGE} \
  -f ${CONTEXT}/server/Dockerfile ${CONTEXT}

retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#push xpra-server to registry during CI only
if [ ! -z ${CI_REGISTRY_IMAGE} ]; then
  REGISTRY_IMAGE=${CI_REGISTRY_IMAGE}/${IMAGE}
  docker tag xpra-server:latest ${REGISTRY_IMAGE}
  docker push ${REGISTRY_IMAGE}
fi
