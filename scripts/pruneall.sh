#!/bin/bash

if [[ $(docker ps -q) ]]; then
  # kill all running containers
  docker kill $(docker ps -q)
fi
if [[ $(docker ps -qa) ]]; then
  # delete all containers
  docker rm $(docker ps -qa)
fi
# prune all networks
docker network prune -f
# prune all volumes
docker volume prune -f
