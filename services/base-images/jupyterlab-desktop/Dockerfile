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
    curl -LO# https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /apps/conda && \
    rm Miniconda3-latest-Linux-x86_64.sh && \
    export PATH=/apps/conda/bin:$PATH && \
    conda install -c conda-forge -y nodejs constructor && \
    npm install -g yarn && \
    cd /apps && \
    curl -L# https://github.com/jupyterlab/jupyterlab-desktop/archive/refs/tags/v${JUPYTERLAB_DESKTOP_VERSION}.tar.gz | tar xzf - && \
    mv jupyterlab-desktop-${JUPYTERLAB_DESKTOP_VERSION} jupyterlab-desktop && \
    cd jupyterlab-desktop && \
    conda update -y nodejs && \
    yarn install && \
    yarn build && \
    yarn create_env_installer:linux && \
    env_installer/JupyterLabDesktopAppServer-*-Linux-x86_64.sh -b -p /apps/jlab_server && \
    # rm -rf env_installer && \
    export PATH=/apps/jlab_server/bin:$PATH && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "Done installing JupyterLab Desktop version ${JUPYTERLAB_DESKTOP_VERSION}"