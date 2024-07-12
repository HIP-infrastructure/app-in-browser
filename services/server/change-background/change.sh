#! /bin/bash


cd "${0%/*}"

docker build -f Dockerfile -t registry.build.chorus-tre.ch/hip/app-in-browser/xpra-server:master ./