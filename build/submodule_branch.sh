#!/bin/bash

for i in services/apps/*/; do
  echo "Updating $i..."
  cd $i;
  git checkout $1
  if [ ! -z "${CI_REGISTRY}" ]; then
    git config --global user.email "no-reply@gitlab.hbp.link"
    git config --global user.name "HBP Gitlab"
  fi
  git config pull.rebase false
  git pull origin $1 --allow-unrelated-histories
  cd - > /dev/null
  echo "Done with $i."
  echo
done
