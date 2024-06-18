# syntax=docker/dockerfile:1
FROM ubuntu:22.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG VERSION
ARG TAG

LABEL base_image_version=$VERSION
LABEL base_image_tag=$TAG

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/curl,sharing=locked \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        curl ca-certificates libglu1-mesa libegl1-mesa libxv1 libxtst6 libegl-mesa0 primus && \
    #curl -sSO https://s3.amazonaws.com/virtualgl-pr/dev/linux/virtualgl_${VERSION}_amd64.deb && \
    #curl -sSO "https://downloads.sourceforge.net/virtualgl/${VERSION}%20(3.0beta1)/virtualgl_2.6.90_amd64.deb" && \
    pushd /var/cache/curl && \
    curl -sSO -C - https://s3.amazonaws.com/virtualgl-pr/main/linux/virtualgl_${VERSION}_amd64.deb && \
    dpkg -i virtualgl_${VERSION}_amd64.deb && \
    popd && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge

COPY ./base-images/virtualgl/config/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

RUN echo "Done installing VirtualGL version ${VERSION}"
