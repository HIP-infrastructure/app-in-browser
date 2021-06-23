#!/bin/bash
# script to test if the directory with path passed in parameter exists and is not empty

if [[ -d $1 && -n "$(ls -A $1)" ]]; then 
  echo -n "davfs2 mounted properly in $1. "
  exit 0
else
  echo -n "davfs2 not mounted properly in $1. "
  exit 1
fi
