#!/bin/bash

SERVER_ID=$1
HIP_USER=$2
NAME=${SERVER_ID}-${HIP_USER}

docker logs xpra-server-${NAME}
