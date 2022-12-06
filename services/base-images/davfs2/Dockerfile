ARG CI_REGISTRY_IMAGE
ARG TAG
ARG TERMINAL_VERSION
FROM ${CI_REGISTRY_IMAGE}/terminal:${TERMINAL_VERSION}${TAG}
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG VERSION

LABEL base_image_version=$VERSION
LABEL base_image_tag=$TAG

RUN apt-get update && \
    apt-get upgrade -y && \
    #apt-get install --no-install-recommends -y davfs2 && \
    apt-get install --no-install-recommends -y \
    curl libneon27 expect && \
    curl -OL# https://launchpad.net/ubuntu/+source/davfs2/${VERSION}/+build/19788214/+files/davfs2_${VERSION}_amd64.deb && \
    dpkg -i davfs2_${VERSION}_amd64.deb && \
    rm davfs2_${VERSION}_amd64.deb && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

RUN echo "Done installing davfs2 version ${VERSION}"
