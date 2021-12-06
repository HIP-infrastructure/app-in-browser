ARG CI_REGISTRY_IMAGE
FROM ${CI_REGISTRY_IMAGE}/terminal
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG DAVFS2_VERSION

LABEL base_image_version=$DAVFS2_VERSION

RUN apt-get update && \
    apt-get upgrade -y && \
    #apt-get install --no-install-recommends -y davfs2 && \
    apt-get install --no-install-recommends -y \
    curl libneon27 expect && \
    curl -O# http://archive.ubuntu.com/ubuntu/pool/universe/d/davfs2/davfs2_${DAVFS2_VERSION}_amd64.deb && \
    dpkg -i davfs2_${DAVFS2_VERSION}_amd64.deb && \
    rm davfs2_${DAVFS2_VERSION}_amd64.deb && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

RUN echo "Done installing nc-webdav version ${DAVFS2_VERSION}"
