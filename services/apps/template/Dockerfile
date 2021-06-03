FROM nc-webdav
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG TEMPLATE_VERSION

LABEL app_version=$TEMPLATE_VERSION

ENV DISPLAY=":80"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    wget sudo && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /apps/template

RUN wget -nv --content-disposition http://template.com/template.zip  && \
    mkdir ./install && \
    unzip -q -d ./template.zip && \
    rm -rf template.zip

# copy entrypoint script and other scripts used in it
COPY ./apps/template/config/docker-entrypoint.sh docker-entrypoint.sh
COPY ./scripts/check-dri.sh scripts/check-dri.sh
COPY ./scripts/create-user.sh scripts/create-user.sh
COPY ./scripts/fix-video-groups.sh scripts/fix-video-groups.sh
COPY ./scripts/mount-davfs2.sh scripts/mount-davfs2.sh
COPY ./scripts/process-healthcheck.sh scripts/process-healthcheck.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
