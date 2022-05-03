ARG CI_REGISTRY_IMAGE
ARG DAVFS2_VERSION
FROM ${CI_REGISTRY_IMAGE}/nc-webdav:${DAVFS2_VERSION}
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG JUPYTERLAB_DESKTOP_VERSION

LABEL base_image_version=${JUPYTERLAB_DESKTOP_VERSION}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    curl && \
    curl -OL# https://github.com/jupyterlab/jupyterlab-desktop/releases/download/v${JUPYTERLAB_DESKTOP_VERSION}/JupyterLab-Setup-Debian.deb  && \
    dpkg -i JupyterLab-Setup-Debian.deb && \ 
    rm -rf JupyterLab-Setup-Debian.deb && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "Done installing JupyterLab Desktop version ${JUPYTERLAB_DESKTOP_VERSION}"
