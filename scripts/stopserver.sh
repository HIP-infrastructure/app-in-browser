#!/bin/bash

SERVER_ID=$1 HIP_USER=$2 COMPOSE_PROJECT_NAME=$1-$2 docker-compose stop xpra-server
