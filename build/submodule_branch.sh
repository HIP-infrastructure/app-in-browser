#!/bin/bash

for i in services/apps/*/; do
  echo "Updating $i..."
  cd $i;
  {
    git checkout $1
    git pull origin $1
  } || {
    git show-ref --verify --quiet refs/heads/main
    if [$1 == "master" && $? == 0]; then
      git checkout main
      git pull origin main
    else
      printf "Failed to checkout $1\nMake sure the branch exists for $i\n"
      exit 1
    fi
  }
  cd - > /dev/null
  echo "Done with $i."
  echo
done
