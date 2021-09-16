#!/bin/bash

./scripts/buildbaseimages.sh && \
./scripts/buildserver.sh && \
./scripts/buildapp.sh brainstorm && \
./scripts/buildapp.sh anywave && \
./scripts/buildapp.sh fsl && \
./scripts/buildapp.sh mricrogl && \
./scripts/buildapp.sh slicer && \
./scripts/buildapp.sh hibop
