#!/bin/bash

SERVER_ID=$1
HIP_USER=$2

docker ps -a --no-trunc --filter name=xpra-server-$SERVER_ID-${HIP_USER}
