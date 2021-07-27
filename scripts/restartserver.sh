#!/bin/bash

SERVER_ID=$1
HIP_USER=$2
NAME=$1-$2

docker restart xpra-server-${NAME}
