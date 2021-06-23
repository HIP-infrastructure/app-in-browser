#!/bin/bash

SERVER_ID=$1
HIP_USER=$2

docker inspect --format "{{json .State.Health }}" xpra-server-$SERVER_ID-${HIP_USER} | jq '.Log[].Output' | tail -1
