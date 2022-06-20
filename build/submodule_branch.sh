#!/bin/bash

for i in services/apps/*/; do
  cd $i;
  git checkout $1
  cd - > /dev/null
done
