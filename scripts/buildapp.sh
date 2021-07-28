#!/bin/bash

#source .env
set -o allexport; source .env; set +o allexport

CONTEXT=./services
APP_NAME=$1
APP_VERSION=${APP_NAME^^}_VERSION

#build ${APP_NAME}
if [ -z ${!APP_VERSION} ]; then
  docker build \
  -t ${APP_NAME}:latest \
  -f ${CONTEXT}/apps/${APP_NAME}/Dockerfile ${CONTEXT}
else
  docker build \
  -t ${APP_NAME}:${!APP_VERSION} \
  --build-arg ${APP_VERSION}=${!APP_VERSION} \
  -f ${CONTEXT}/apps/${APP_NAME}/Dockerfile ${CONTEXT}
fi
