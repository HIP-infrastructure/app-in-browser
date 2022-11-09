ARG CI_REGISTRY_IMAGE
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG VERSION

LABEL base_image_version=${VERSION}

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
    curl -L# https://github.com/jupyterlab/jupyterlab-desktop/archive/refs/tags/v${VERSION}.tar.gz | tar xzf - && \
    mv jupyterlab-desktop-${VERSION} jupyterlab-desktop && \
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

RUN echo "Done installing JupyterLab Desktop version ${DESKTOP_VERSION}"
