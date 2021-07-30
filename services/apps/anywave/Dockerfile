ARG DAVFS2_VERSION
FROM nc-webdav:${DAVFS2_VERSION}
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG ANYWAVE_VERSION

LABEL app_version=$ANYWAVE_VERSION

ENV DISPLAY=":80"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    wget sudo \
    libqt5charts5 libqt5concurrent5 libqt5multimediawidgets5 \
    libqt5printsupport5 libqt5qml5 libmatio9 libvtk7.1p-qt \
    libqwt-qt5-6 libqt5xml5 libqcustomplot2.0 libtbb2 && \ 
    wget -nv https://meg.univ-amu.fr/AnyWave/anywave-${ANYWAVE_VERSION}_amd64.deb && \
    dpkg -i anywave-${ANYWAVE_VERSION}_amd64.deb && \
    rm anywave-${ANYWAVE_VERSION}_amd64.deb && \
    apt-get remove -y --purge wget && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /apps/anywave

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/anywave/scripts/process-healthcheck.sh /usr/local/AnyWave/AnyWaveLinux \
  && /apps/anywave/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

# copy entrypoint script and other scripts used in it
COPY ./apps/anywave/config/docker-entrypoint.sh docker-entrypoint.sh
COPY ./scripts/check-dri.sh scripts/check-dri.sh
COPY ./scripts/create-user.sh scripts/create-user.sh
COPY ./scripts/fix-video-groups.sh scripts/fix-video-groups.sh
COPY ./scripts/mount-davfs2.sh scripts/mount-davfs2.sh
COPY ./scripts/homedir-symlink.sh scripts/homedir-symlink.sh
COPY ./scripts/process-healthcheck.sh scripts/process-healthcheck.sh
COPY ./scripts/ls-healthcheck.sh scripts/ls-healthcheck.sh
COPY ./scripts/run-app.sh scripts/run-app.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
