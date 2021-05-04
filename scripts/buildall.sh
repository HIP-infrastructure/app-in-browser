#!/bin/bash

docker-compose build vgl-base && \
docker-compose build nc-webdav && \
docker-compose build matlab-runtime && \
docker-compose build xpra-server && \
docker-compose build brainstorm
