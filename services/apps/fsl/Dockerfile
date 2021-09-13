ARG CI_REGISTRY_IMAGE
ARG DAVFS2_VERSION
FROM ${CI_REGISTRY_IMAGE}/nc-webdav:${DAVFS2_VERSION}
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION

WORKDIR /apps/${APP_NAME}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    curl file python && \
    curl -O https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py && \
    python fslinstaller.py -d /usr/local/fsl -V ${APP_VERSION} && \
    rm fslinstaller.py && \
    rm -rf /usr/local/fsl/src && \
    apt-get remove -y --purge curl file && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV APP_SHELL="yes"
ENV APP_CMD=""
ENV PROCESS_NAME=""
ENV DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
