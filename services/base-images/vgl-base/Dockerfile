FROM ubuntu:20.04
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG VIRTUALGL_VERSION

LABEL base_image_version=$VIRTUALGL_VERSION

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    ca-certificates wget libglu1-mesa libegl1-mesa libxv1 libxtst6 && \
    wget -nv https://s3.amazonaws.com/virtualgl-pr/dev/linux/virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    rm virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    apt-get remove -y --purge wget && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

COPY ./base-images/vgl-base/config/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

RUN echo "Done installing VirtualGL version ${VIRTUALGL_VERSION}"
