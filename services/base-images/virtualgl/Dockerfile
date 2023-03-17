FROM ubuntu:20.04
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG VERSION
ARG TAG

LABEL base_image_version=$VERSION
LABEL base_image_tag=$TAG

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    curl ca-certificates libglu1-mesa libegl1-mesa libxv1 libxtst6 && \
    #curl -sSO https://s3.amazonaws.com/virtualgl-pr/dev/linux/virtualgl_${VERSION}_amd64.deb && \
    #curl -sSO "https://downloads.sourceforge.net/virtualgl/${VERSION}%20(3.0beta1)/virtualgl_2.6.90_amd64.deb" && \
    curl -sSO https://s3.amazonaws.com/virtualgl-pr/main/linux/virtualgl_${VERSION}_amd64.deb && \
    dpkg -i virtualgl_${VERSION}_amd64.deb && \
    rm virtualgl_${VERSION}_amd64.deb && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./base-images/virtualgl/config/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

RUN echo "Done installing VirtualGL version ${VERSION}"
