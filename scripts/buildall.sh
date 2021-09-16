#!/bin/bash

./scripts/buildbaseimages.sh
retVal=$?
if [ $retVal -ne 0 ]; then
  exit 1
fi

./scripts/buildserver.sh
retVal=$?
if [ $retVal -ne 0 ]; then
  exit 1
fi

APP_LIST=(
  anywave
  brainstorm
  fsl
  hibop
  localizer
  mricrogl
  slicer
)

for app in ${APP_LIST[@]}; do
  ./scripts/buildapp.sh $app
  retVal=$?
  if [ $retVal -ne 0 ]; then
    exit 1
  fi
done
