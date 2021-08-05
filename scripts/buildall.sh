#!/bin/bash

pwd
./scripts/buildbaseimages.sh && \
./scripts/buildserver.sh && \
./scripts/buildapp.sh brainstorm && \
./scripts/buildapp.sh anywave
