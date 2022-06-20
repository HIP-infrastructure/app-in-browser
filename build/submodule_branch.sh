#!/bin/bash

for i in services/apps/*/; do
  cd $i;
  git checkout $1
  git pull origin $1
  cd - > /dev/null
done
