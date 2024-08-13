FROM ubuntu:22.04
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG VERSION
ARG TAG

LABEL base_image_version=$VERSION
LABEL base_image_tag=$TAG

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -q && \
    apt-get upgrade -qy && \
    apt-get install --no-install-recommends -y \
        curl ca-certificates libglu1-mesa libegl1-mesa libxv1 libxtst6 libegl-mesa0 primus gpg && \
    curl -fsSL https://packagecloud.io/dcommander/virtualgl/gpgkey | \
        gpg --yes --dearmor -o /usr/share/keyrings/virtualgl.gpg && \
    echo 'deb [signed-by=/usr/share/keyrings/virtualgl.gpg] https://packagecloud.io/dcommander/virtualgl/any/ any main' | \
        tee /etc/apt/sources.list.d/virtualgl.list && \
    apt-get update -q && \
    version=$(apt-cache madison virtualgl | grep -o "${VERSION}-[0-9]*") && \
    apt-get install --no-install-recommends -y \
        virtualgl=${version} && \
    apt-get remove -y --purge curl gpg && \
    apt-get autoremove -y --purge

COPY ./base-images/virtualgl/config/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

RUN echo "Done installing VirtualGL version ${VERSION}"
