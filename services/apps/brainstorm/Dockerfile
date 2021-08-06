ARG CI_REGISTRY_IMAGE
FROM ${CI_REGISTRY_IMAGE}/matlab-runtime:R2020a_u6
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
#ARG BRAINSTORM_VERSION

#LABEL app_version=$BRAINSTORM_VERSION

ENV DISPLAY=":80"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    wget default-jre sudo && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /apps/brainstorm

#RUN wget -nv --content-disposition https://neuroimage.usc.edu/bst/download.php?file=brainstorm_${BRAINSTORM_VERSION}.zip && \
RUN wget -nv --content-disposition http://neuroimage.usc.edu/bst/getupdate.php?c=UbsM09  && \
    mkdir -p ./run/brainstorm_db && \
    mkdir ./install && \
    #unzip -q -d ./install brainstorm_${BRAINSTORM_VERSION}.zip && \
    #rm -rf brainstormi_${BRAINSTORM_VERSION}.zip
    unzip -q -d ./install brainstorm_*.zip && \
    rm -rf brainstorm_*.zip

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/brainstorm/scripts/process-healthcheck.sh brainstorm3.jar \
  && /apps/brainstorm/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

# copy entrypoint script and other scripts used in it
COPY ./apps/brainstorm/config/docker-entrypoint.sh docker-entrypoint.sh
COPY ./scripts/check-dri.sh scripts/check-dri.sh
COPY ./scripts/create-user.sh scripts/create-user.sh
COPY ./scripts/fix-video-groups.sh scripts/fix-video-groups.sh
COPY ./scripts/mount-davfs2.sh scripts/mount-davfs2.sh
COPY ./scripts/homedir-symlink.sh scripts/homedir-symlink.sh
COPY ./scripts/process-healthcheck.sh scripts/process-healthcheck.sh
COPY ./scripts/ls-healthcheck.sh scripts/ls-healthcheck.sh
COPY ./scripts/run-app.sh scripts/run-app.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
