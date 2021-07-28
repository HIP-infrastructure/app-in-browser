#!/bin/bash

#source .env
set -o allexport; source .env; set +o allexport

CONTEXT=./services

#build xpra-server
docker build \
  --build-arg VIRTUALGL_VERSION=${VIRTUALGL_VERSION} \
  -t xpra-server:latest \
  -f ${CONTEXT}/server/Dockerfile ${CONTEXT}
