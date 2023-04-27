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

WORKDIR /apps/jupyterlab-desktop

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    curl libgtk-3-0 libnotify4 libnss3 libxss1 \
    xdg-utils libatspi2.0-0 libsecret-1-0 \
    libasound2 libsecret-common && \
    #install conda
    curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p $PWD/conda && \
    rm -rf Miniconda3-latest-Linux-x86_64.sh && \
    #install jlabdesktop
    curl -sSLO https://github.com/jupyterlab/jupyterlab-desktop/releases/download/v${VERSION}/JupyterLab-Setup-Debian.deb && \
    dpkg -i JupyterLab-Setup-Debian.deb && \
    rm -rf JupyterLab-Setup-Debian.deb && \
    #install mamba (package manager) and new env for jlabdesktop
    export PATH="/apps/jupyterlab-desktop/conda/bin:${PATH}" && \
    conda install --channel=conda-forge --name=base mamba && \
    mamba create -y --override-channels --channel=conda-forge --name=jlab_env pip nb_conda_kernels ipykernel jupyterlab && \
    #cleanup
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "Done installing JupyterLab Desktop version ${DESKTOP_VERSION}"
