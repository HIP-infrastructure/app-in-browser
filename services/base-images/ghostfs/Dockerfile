ARG CI_REGISTRY_IMAGE
ARG TAG
ARG TERMINAL_VERSION
FROM ${CI_REGISTRY_IMAGE}/terminal:${TERMINAL_VERSION}${TAG}
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG VERSION
ARG TAG

LABEL base_image_version=$VERSION
LABEL base_image_tag=$TAG

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    fuse libfuse2 binutils curl && \
    curl -sSOL https://github.com/pouya-eghbali/ghostfs-builds/releases/download/linux-ubuntu-22.04-${VERSION}${TAG}/GhostFS && \
    chmod +x GhostFS && \
    mv GhostFS /usr/bin && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

RUN echo "Done installing ghostfs version ${VERSION}"
