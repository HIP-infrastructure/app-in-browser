#!/bin/bash

#source .env
set -o allexport; source .env; set +o allexport

CONTEXT="./services"
IMAGE="xpra-server:latest"

#pull image and cache from registry during CI only
if [ ! -z ${CI_REGISTRY_IMAGE} ]; then
  REGISTRY_IMAGE=${CI_REGISTRY_IMAGE}/${IMAGE}
  docker pull ${REGISTRY_IMAGE} || true
  CACHE_OPTS="--cache-from ${REGISTRY_IMAGE}"
fi

#build xpra-server
docker build \
  --build-arg VIRTUALGL_VERSION=${VIRTUALGL_VERSION} \
  ${CACHE_OPTS} \
  -t ${IMAGE} \
  -f ${CONTEXT}/server/Dockerfile ${CONTEXT}

retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#push xpra-server to registry during CI only
if [ ! -z ${CI_REGISTRY_IMAGE} ]; then
  REGISTRY_IMAGE=${CI_REGISTRY_IMAGE}/${IMAGE}
  docker tag ${IMAGE} ${REGISTRY_IMAGE}
  docker push ${REGISTRY_IMAGE}
fi
