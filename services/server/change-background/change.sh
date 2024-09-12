#! /bin/bash


cd "${0%/*}"

docker build -f Dockerfile -t registry.hbp.link/hip/app-in-browser/xpra-server:chorusbg ./
docker push registry.hbp.link/hip/app-in-browser/xpra-server:chorusbg
