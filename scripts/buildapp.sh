#!/bin/bash

#source .env
set -o allexport; source .env; set +o allexport

CONTEXT="./services"
APP_NAME=$1
APP_VERSION=${APP_NAME^^}_VERSION

#build ${APP_NAME}
if [ -z ${!APP_VERSION} ]; then
  IMAGE=${APP_NAME}:latest
  docker build \
  -t ${IMAGE} \
  -f ${CONTEXT}/apps/${APP_NAME}/Dockerfile ${CONTEXT}

  retVal=$?
  if [ $retVal -ne 0 ]; then
    exit $retVal
  fi
else
  IMAGE=${APP_NAME}:${!APP_VERSION}
  docker build \
  -t ${IMAGE} \
  --build-arg ${APP_VERSION}=${!APP_VERSION} \
  --build-arg DAVFS2_VERSION=${DAVFS2_VERSION} \
  -f ${CONTEXT}/apps/${APP_NAME}/Dockerfile ${CONTEXT}

  retVal=$?
  if [ $retVal -ne 0 ]; then
    exit $retVal
  fi
fi

#push ${APP_NAME} to registry during CI only
if [ ! -z ${CI_REGISTRY_IMAGE} ]; then
  REGISTRY_IMAGE=${CI_REGISTRY_IMAGE}/${IMAGE}
  docker tag ${IMAGE} ${REGISTRY_IMAGE}
  docker push ${REGISTRY_IMAGE}
fi
