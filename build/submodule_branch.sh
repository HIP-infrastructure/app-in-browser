#!/bin/bash

for i in services/apps/*/; do
  echo "Updating $i..."
  cd $i;
  git checkout $1
  git pull origin $1
  git config pull.rebase false
  git pull origin $1
  cd - > /dev/null
  echo "Done with $i."
  echo
done
