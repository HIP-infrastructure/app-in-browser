#!/bin/bash

SERVER_ID=$2 APP_ID=$3 NEXTCLOUD_USERNAME=$4 COMPOSE_PROJECT_NAME=$2-$4 docker-compose up -d $1
