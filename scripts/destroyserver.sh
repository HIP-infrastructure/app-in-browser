#!/bin/bash

SERVER_ID=$1
HIP_USER=$2

docker rm xpra-server-$SERVER_ID-${HIP_USER}

docker network rm $SERVER_ID-${HIP_USER}_server
docker network rm $SERVER_ID-${HIP_USER}_apps
docker network rm $SERVER_ID-${HIP_USER}_default

docker volume rm $SERVER_ID-${HIP_USER}_x11-unix
