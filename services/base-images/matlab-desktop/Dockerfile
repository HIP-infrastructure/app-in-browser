ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG}
LABEL maintainer="florian.sipp@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG VERSION

LABEL base_image_version=${VERSION}
LABEL base_image_tag=${TAG}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    curl unzip libxt6 libxft2 && \
    mkdir /apps/mpm && \
    cd /apps/mpm && \
    curl -sSOL https://www.mathworks.com/mpm/glnxa64/mpm && \
    chmod +x mpm && \
    ./mpm install --release=R2023a --destination=/opt/matlab/R2023a MATLAB Signal_Processing_Toolbox Parallel_Computing_Toolbox && \
    rm -rf /apps/mpm && \
    apt-get remove -y --purge curl unzip && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "Done installing matlab"
