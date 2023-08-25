#!/bin/bash

for i in services/apps/*/; do
  echo "Updating $i..."
  cd $i;
  git checkout $1
  if [ -z "${CI_REGISTRY}" ]; then
    git config pull.rebase false
  fi
  git pull origin $1
  cd - > /dev/null
  echo "Done with $i."
  echo
done
