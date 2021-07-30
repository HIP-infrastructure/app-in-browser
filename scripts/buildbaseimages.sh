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
  --build-arg DAVFS2_VERSION=${DAVFS2_VERSION} \
  -t nc-webdav:${DAVFS2_VERSION} \
  -f ${CONTEXT}/base-images/nc-webdav/Dockerfile ${CONTEXT} &&

#build each matlab-runtime
for i in "${!MATLAB_RUNTIME_VERSIONS[@]}"; do
  docker build \
    --build-arg DAVFS2_VERSION=${DAVFS2_VERSION} \
    --build-arg MATLAB_RUNTIME_VERSION=${MATLAB_RUNTIME_VERSIONS[i]} \
    --build-arg MATLAB_RUNTIME_UPDATE=${MATLAB_RUNTIME_UPDATES[i]} \
    -t matlab-runtime:${MATLAB_RUNTIME_VERSIONS[i]}_u${MATLAB_RUNTIME_UPDATES[i]} \
    -f ${CONTEXT}/base-images/matlab-runtime/Dockerfile ${CONTEXT}
    echo "${MATLAB_RUNTIME_VERSIONS[i]}_u${MATLAB_RUNTIME_UPDATES[i]}"
done
