#!/bin/bash

#source .env
set -o allexport; source .env; set +o allexport

CONTEXT="./services"

##### vgl-base #####
REGISTRY_IMAGE=${CI_REGISTRY_IMAGE}/vgl-base:${VIRTUALGL_VERSION}

#pull vgl-base and cache from registry during CI only
if [ ! -z ${CI_REGISTRY} ]; then
  docker pull ${REGISTRY_IMAGE} || true
  CACHE_OPTS="--cache-from ${REGISTRY_IMAGE}"
fi

#build vgl-base
docker build \
  --build-arg VIRTUALGL_VERSION=${VIRTUALGL_VERSION} \
  ${CACHE_OPTS} \
  -t ${REGISTRY_IMAGE} \
  -f ${CONTEXT}/base-images/vgl-base/Dockerfile ${CONTEXT}

retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#push vgl-base to registry during CI only
if [ ! -z ${CI_REGISTRY} ]; then
  docker push ${REGISTRY_IMAGE}
fi

##### terminal #####
REGISTRY_IMAGE=${CI_REGISTRY_IMAGE}/terminal

#pull terminal and cache from registry during CI only
if [ ! -z ${CI_REGISTRY} ]; then
  docker pull ${REGISTRY_IMAGE} || true
  CACHE_OPTS="--cache-from ${REGISTRY_IMAGE}"
fi

#build build
docker build \
  --build-arg CI_REGISTRY_IMAGE=${CI_REGISTRY_IMAGE} \
  --build-arg VIRTUALGL_VERSION=${VIRTUALGL_VERSION} \
  ${CACHE_OPTS} \
  -t ${REGISTRY_IMAGE} \
  -f ${CONTEXT}/base-images/terminal/Dockerfile ${CONTEXT} &&

retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#push terminal to registry during CI only
if [ ! -z ${CI_REGISTRY} ]; then
  docker push ${REGISTRY_IMAGE}
fi

##### nc-webdav #####
REGISTRY_IMAGE=${CI_REGISTRY_IMAGE}/nc-webdav:${DAVFS2_VERSION}

#pull nc-webdav and cache from registry during CI only
if [ ! -z ${CI_REGISTRY} ]; then
  docker pull ${REGISTRY_IMAGE} || true
  CACHE_OPTS="--cache-from ${REGISTRY_IMAGE}"
fi

#build nc-webdav
docker build \
  --build-arg CI_REGISTRY_IMAGE=${CI_REGISTRY_IMAGE} \
  --build-arg DAVFS2_VERSION=${DAVFS2_VERSION} \
  ${CACHE_OPTS} \
  -t ${REGISTRY_IMAGE} \
  -f ${CONTEXT}/base-images/nc-webdav/Dockerfile ${CONTEXT} &&

retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#push nc-webdav to registry during CI only
if [ ! -z ${CI_REGISTRY} ]; then
  docker push ${REGISTRY_IMAGE}
fi

##### matlab-runtime #####
for i in "${!MATLAB_RUNTIME_VERSIONS[@]}"; do
  REGISTRY_IMAGE=${CI_REGISTRY_IMAGE}/matlab-runtime:${MATLAB_RUNTIME_VERSIONS[i]}_u${MATLAB_RUNTIME_UPDATES[i]}

  #pull each matlab-runtime and cache from registry during CI only
  if [ ! -z ${CI_REGISTRY} ]; then
    docker pull ${REGISTRY_IMAGE} || true
    CACHE_OPTS="--cache-from ${REGISTRY_IMAGE}"
  fi

  #build each matlab-runtime
  docker build \
    --build-arg CI_REGISTRY_IMAGE=${CI_REGISTRY_IMAGE} \
    --build-arg DAVFS2_VERSION=${DAVFS2_VERSION} \
    --build-arg MATLAB_RUNTIME_VERSION=${MATLAB_RUNTIME_VERSIONS[i]} \
    --build-arg MATLAB_RUNTIME_UPDATE=${MATLAB_RUNTIME_UPDATES[i]} \
    ${CACHE_OPTS} \
    -t ${REGISTRY_IMAGE} \
    -f ${CONTEXT}/base-images/matlab-runtime/Dockerfile ${CONTEXT}

  retVal=$?
  if [ $retVal -ne 0 ]; then
    exit $retVal
  fi

  #push matlab-runtime to registry during CI only
  if [ ! -z ${CI_REGISTRY} ]; then
    docker push ${REGISTRY_IMAGE}
  fi
done
