ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG}

ARG VERSION
ARG TAG

LABEL base_image_version=${VERSION}
LABEL base_image_tag=${TAG}

WORKDIR /apps/jupyterlab-desktop

ENV PATH="/apps/jupyterlab-desktop/conda/bin:${PATH}"

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        curl \
        libarchive13 \
        libasound2 \
        libatspi2.0-0 \
        libgtk-3-0 \
        libnotify4 \
        libnss3 \
        libsecret-1-0 \
        libsecret-common \
        libxss1 \
        xdg-utils && \
    #install conda
    curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p $PWD/conda && \
    rm -rf Miniconda3-latest-Linux-x86_64.sh && \
    # install jlabdesktop
    curl -sSL -C - -o JupyterLab-Setup-${VERSION}.deb "https://github.com/jupyterlab/jupyterlab-desktop/releases/download/v${VERSION}/JupyterLab-Setup-Debian-x64.deb" && \
    dpkg -i JupyterLab-Setup-${VERSION}.deb && \
    rm -rf JupyterLab-Setup-${VERSION}.deb && \
    # install mamba (package manager) and new env for jlabdesktop
    conda install --channel=conda-forge --name=base mamba && \
    mamba create -y --override-channels --channel=conda-forge --name=jlab_env pip nb_conda_kernels ipykernel jupyterlab && \
    # cleanup
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge && \
    apt-get clean

RUN echo "Done installing JupyterLab Desktop version ${DESKTOP_VERSION}"
