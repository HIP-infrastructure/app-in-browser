#!/bin/bash

#source .env
set -o allexport; source .env; set +o allexport

CONTEXT="./services"
IMAGE="xpra-server:${XPRA_VERSION}"
REGISTRY_IMAGE=${CI_REGISTRY_IMAGE}/${IMAGE}

#pull xpra-server and cache from registry during CI only
if [ ! -z ${CI_REGISTRY} ]; then
  docker pull ${REGISTRY_IMAGE} || true
  CACHE_OPTS="--cache-from ${REGISTRY_IMAGE}"
fi

#build xpra-server
docker build \
  --build-arg CI_REGISTRY_IMAGE=${CI_REGISTRY_IMAGE} \
  --build-arg XPRA_VERSION=${XPRA_VERSION} \
  --build-arg VIRTUALGL_VERSION=${VIRTUALGL_VERSION} \
  ${CACHE_OPTS} \
  -t ${REGISTRY_IMAGE} \
  -f ${CONTEXT}/server/Dockerfile.${XPRA_VERSION} ${CONTEXT}

retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#push xpra-server to registry during CI only
if [ ! -z ${CI_REGISTRY} ]; then
  docker push ${REGISTRY_IMAGE}
fi
