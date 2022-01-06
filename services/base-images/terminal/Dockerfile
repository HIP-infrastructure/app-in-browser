ARG CI_REGISTRY_IMAGE
ARG VIRTUALGL_VERSION
FROM ${CI_REGISTRY_IMAGE}/vgl-base:${VIRTUALGL_VERSION}
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
#ARG HYPER_VERSION

#LABEL app_version=$HYPER_VERSION

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    curl libgtk-3-0 libnotify4 libnss3 libxss1 xdg-utils \
    libatspi2.0-0 libappindicator3-1 libsecret-1-0 libasound2 && \
    curl -LJO# https://releases.hyper.is/download/deb && \
    dpkg -i hyper*.deb && \
    rm hyper*.deb && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "Done installing Terminal"
