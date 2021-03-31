#!/bin/bash

SERVER_ID=$2 APP_ID=$3 HIP_USER=$4 COMPOSE_PROJECT_NAME=$2-$4 docker-compose stop $1
