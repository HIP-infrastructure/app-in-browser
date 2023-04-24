ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG}
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG VERSION

LABEL base_image_version=${VERSION}
LABEL base_image_tag=${TAG}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    curl libgtk-3-0 libnotify4 libnss3 libxss1 \
    xdg-utils libatspi2.0-0 libsecret-1-0 \
    libasound2 && \
    curl -sSLO https://github.com/jupyterlab/jupyterlab-desktop/releases/download/v${VERSION}/JupyterLab-Setup-Debian.deb && \
    dpkg -i JupyterLab-Setup-Debian.deb && \
    rm -rf JupyterLab-Setup-Debian.deb && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "Done installing JupyterLab Desktop version ${DESKTOP_VERSION}"
