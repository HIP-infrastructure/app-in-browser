#!/bin/bash

if [[ $(docker ps -q) ]]; then
  echo "Killing all running containers..."
  docker kill $(docker ps -q)
else
  echo "No running containers found."
fi

if [[ $(docker ps -qa) ]]; then
  echo "Deleting all containers..."
  docker rm $(docker ps -qa)
else
  echo "No containers to delete."
fi

echo "Pruning networks..."
docker network prune -f

echo "Pruning all volumes..."
docker volume prune -f
