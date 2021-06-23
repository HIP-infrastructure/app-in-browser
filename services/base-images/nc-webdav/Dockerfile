ARG VIRTUALGL_VERSION
FROM vgl-base:${VIRTUALGL_VERSION}
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y davfs2 && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

WORKDIR /base-images/nc-webdav

RUN echo "Done installing nc-webdav"
