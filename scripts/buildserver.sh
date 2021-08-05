#!/bin/bash

#source .env
set -o allexport; source .env; set +o allexport

CONTEXT=./services

#build xpra-server
docker build \
  --build-arg VIRTUALGL_VERSION=${VIRTUALGL_VERSION} \
  -t xpra-server:latest \
  -f ${CONTEXT}/server/Dockerfile ${CONTEXT}

#push to registry during CI only
if [ ! -z ${CI_REGISTRY} ]; then
  REGISTRY_IMAGE=${CI_REGISTRY}/${CI_REGISTRY_IMAGE}:latest
  docker tag xpra-server:latest ${REGISTRY_IMAGE}
  docker push ${REGISTRY_IMAGE}
fi
