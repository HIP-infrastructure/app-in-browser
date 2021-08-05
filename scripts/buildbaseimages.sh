#!/bin/bash

#source .env
set -o allexport; source .env; set +o allexport

CONTEXT="./services"

#build vgl-base
docker build \
  --build-arg VIRTUALGL_VERSION=${VIRTUALGL_VERSION} \
  -t vgl-base:${VIRTUALGL_VERSION} \
  -f ${CONTEXT}/base-images/vgl-base/Dockerfile ${CONTEXT}

retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#push vgl-base to registry during CI only
if [ ! -z ${CI_REGISTRY_IMAGE} ]; then
  REGISTRY_IMAGE=${CI_REGISTRY_IMAGE}/vgl-base:${VIRTUALGL_VERSION}
  docker tag vgl-base:${VIRTUALGL_VERSION} ${REGISTRY_IMAGE}
  docker push ${REGISTRY_IMAGE}
fi

#build nc-webdav
docker build \
  --build-arg VIRTUALGL_VERSION=${VIRTUALGL_VERSION} \
  --build-arg DAVFS2_VERSION=${DAVFS2_VERSION} \
  -t nc-webdav:${DAVFS2_VERSION} \
  -f ${CONTEXT}/base-images/nc-webdav/Dockerfile ${CONTEXT} &&

retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

#push nc-webdav to registry during CI only
if [ ! -z ${CI_REGISTRY_IMAGE} ]; then
  REGISTRY_IMAGE=${CI_REGISTRY_IMAGE}/nc-webdav:${DAVFS2_VERSION}
  docker tag nc-webdav:${DAVFS2_VERSION} ${REGISTRY_IMAGE}
  docker push ${REGISTRY_IMAGE}
fi

#build each matlab-runtime
for i in "${!MATLAB_RUNTIME_VERSIONS[@]}"; do
  docker build \
    --build-arg DAVFS2_VERSION=${DAVFS2_VERSION} \
    --build-arg MATLAB_RUNTIME_VERSION=${MATLAB_RUNTIME_VERSIONS[i]} \
    --build-arg MATLAB_RUNTIME_UPDATE=${MATLAB_RUNTIME_UPDATES[i]} \
    -t matlab-runtime:${MATLAB_RUNTIME_VERSIONS[i]}_u${MATLAB_RUNTIME_UPDATES[i]} \
    -f ${CONTEXT}/base-images/matlab-runtime/Dockerfile ${CONTEXT}

  retVal=$?
  if [ $retVal -ne 0 ]; then
    exit $retVal
  fi

  #push matlab-runtime to registry during CI only
  if [ ! -z ${CI_REGISTRY_IMAGE} ]; then
    REGISTRY_IMAGE=${CI_REGISTRY_IMAGE}/matlab-runtime:${MATLAB_RUNTIME_VERSIONS[i]}_u${MATLAB_RUNTIME_UPDATES[i]}
    docker tag matlab-runtime:${MATLAB_RUNTIME_VERSIONS[i]}_u${MATLAB_RUNTIME_UPDATES[i]} ${REGISTRY_IMAGE}
    docker push ${REGISTRY_IMAGE}
  fi
done
