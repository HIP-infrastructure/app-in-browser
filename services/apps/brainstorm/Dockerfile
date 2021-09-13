ARG CI_REGISTRY_IMAGE
FROM ${CI_REGISTRY_IMAGE}/matlab-runtime:R2020a_u6
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
    curl unzip default-jre && \
    #curl -J -O https://neuroimage.usc.edu/bst/download.php?file=brainstorm_${APP_VERSION}.zip && \
    curl -J -O http://neuroimage.usc.edu/bst/getupdate.php?c=UbsM09  && \
    mkdir -p ./run/brainstorm_db && \
    mkdir ./install && \
    #unzip -q -d ./install brainstorm_${APP_VERSION}.zip && \
    #rm -rf brainstormi_${APP_VERSION}.zip
    unzip -q -d ./install brainstorm_*.zip && \
    rm -rf brainstorm_*.zip && \
    apt-get remove -y --purge curl unzip && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV APP_SHELL="no"
ENV APP_CMD="/apps/brainstorm/install/brainstorm3/bin/R2020a/brainstorm3.command /usr/local/MATLAB/MATLAB_Runtime/v98"
ENV PROCESS_NAME="brainstorm3.jar"
ENV DIR_ARRAY="brainstorm_db .brainstorm"
#ENV DIR_ARRAY="brainstorm_db .brainstorm .mcrCache9.8"

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
