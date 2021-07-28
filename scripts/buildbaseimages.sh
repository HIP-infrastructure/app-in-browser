#!/bin/bash

#source .env
set -o allexport; source .env; set +o allexport

CONTEXT=./services

#build vgl-base
docker build \
  --build-arg VIRTUALGL_VERSION=${VIRTUALGL_VERSION} \
  -t vgl-base:${VIRTUALGL_VERSION} \
  -f ${CONTEXT}/base-images/vgl-base/Dockerfile ${CONTEXT} &&

#build nc-webdav
docker build \
  --build-arg VIRTUALGL_VERSION=${VIRTUALGL_VERSION} \
  -t nc-webdav:latest \
  -f ${CONTEXT}/base-images/nc-webdav/Dockerfile ${CONTEXT} &&

#build matlab-runtime
docker build \
  --build-arg MATLAB_RUNTIME_VERSION=${MATLAB_RUNTIME_VERSION} \
  --build-arg MATLAB_RUNTIME_UPDATE=${MATLAB_RUNTIME_UPDATE} \
  -t matlab-runtime:${MATLAB_RUNTIME_VERSION}_u${MATLAB_RUNTIME_UPDATE} \
  -f ${CONTEXT}/base-images/matlab-runtime/Dockerfile ${CONTEXT}
