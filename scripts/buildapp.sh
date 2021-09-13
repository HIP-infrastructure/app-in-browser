#!/bin/bash

#source .env
set -o allexport; source .env; set +o allexport

CONTEXT="./services"
APP_NAME=$1
APP_VERSION=${APP_NAME^^}_VERSION

#check if ${APP_NAME} has a version number
if [ -z ${!APP_VERSION} ]; then
  IMAGE=${APP_NAME}:latest
  REGISTRY_IMAGE=${CI_REGISTRY_IMAGE}/${IMAGE}
  APP_VERSION_OPTS="--build-arg APP_VERSION=latest"
else
  IMAGE=${APP_NAME}:${!APP_VERSION}
  REGISTRY_IMAGE=${CI_REGISTRY_IMAGE}/${IMAGE}
  APP_VERSION_OPTS="--build-arg APP_VERSION=${!APP_VERSION}"
fi

#pull ${APP_NAME} and cache from registry during CI only
if [ ! -z ${CI_REGISTRY} ]; then
  docker pull ${REGISTRY_IMAGE} || true
  CACHE_OPTS="--cache-from ${REGISTRY_IMAGE}"
fi

#build ${APP_NAME}
docker build \
--build-arg CI_REGISTRY_IMAGE=${CI_REGISTRY_IMAGE} \
--build-arg APP_NAME=${APP_NAME} \
${APP_VERSION_OPTS} \
--build-arg DAVFS2_VERSION=${DAVFS2_VERSION} \
${CACHE_OPTS} \
-t ${REGISTRY_IMAGE} \
-f ${CONTEXT}/apps/${APP_NAME}/Dockerfile ${CONTEXT}

retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#push ${APP_NAME} to registry during CI only
if [ ! -z ${CI_REGISTRY} ]; then
  docker push ${REGISTRY_IMAGE}
fi
