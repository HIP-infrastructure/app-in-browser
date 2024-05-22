# syntax=docker/dockerfile:1
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

#Reference for dependencies for each matlab versions:
#https://github.com/mathworks-ref-arch/container-images/tree/main/matlab-deps
#Issue for R2023a and Ubuntu22.04:
#https://www.mathworks.com/matlabcentral/answers/1978579-why-do-some-matlab-features-fail-on-ubuntu-23-04-and-debian-12-with-exit-code-127-in-matlab-r2022b-a
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/curl,sharing=locked \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    curl ca-certificates libasound2 libc6 libcairo-gobject2 libcairo2 libcap2 \
    libcrypt1 libcups2 libdrm2 libgbm1 libgdk-pixbuf-2.0-0 libgl1 libglib2.0-0 \
    libgstreamer-plugins-base1.0-0 libgstreamer1.0-0 libgtk-3-0 libice6 libnspr4 \
    libnss3 libodbc2 libodbcinst2 libpam0g libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 \
    libpython3.10 libsndfile1 libuuid1 libwayland-client0 libxcomposite1 libxcursor1 libxdamage1 \
    libxfixes3 libxft2 libxinerama1 libxrandr2 libxt6 libxtst6 libxxf86vm1 locales locales-all make net-tools procps unzip zlib1g && \
    pushd /var/cache/curl && \
    curl -sSOL -C - https://www.mathworks.com/mpm/glnxa64/mpm && \
    chmod +x mpm && \
    ./mpm install --release=R2023a --destination=/opt/matlab/R2023a MATLAB Signal_Processing_Toolbox Parallel_Computing_Toolbox && \
    popd && \
    # If libfreetype.so.6 is not removed, java error when trying to open the matlab code editor \
    rm -rf /opt/matlab/R2023a/bin/glnxa64/libfreetype.so.6 && \
    apt-get remove -y --purge curl unzip && \
    apt-get autoremove -y --purge

RUN echo "Done installing matlab"
