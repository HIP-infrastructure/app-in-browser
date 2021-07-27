#!/bin/bash

SERVER_ID=$1
HIP_USER=$2

docker stop xpra-server-${SERVER_ID}-${HIP_USER}
