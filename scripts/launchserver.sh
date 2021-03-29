#!/bin/bash

SERVER_ID=$1 NEXTCLOUD_USERNAME=$2 COMPOSE_PROJECT_NAME=$1-$2 docker-compose up -d xpra-server
