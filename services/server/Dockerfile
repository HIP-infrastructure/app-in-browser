ARG VIRTUALGL_VERSION
FROM vgl-base:${VIRTUALGL_VERSION}
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    software-properties-common wget gnupg \
    xvfb x11-xserver-utils python3-pip \
    python3-xdg menu-xdg curl && \
    pip3 install pyinotify && \
    wget -q https://xpra.org/gpg.asc -O- | apt-key add - && \
    add-apt-repository "deb https://xpra.org/ groovy main" && \
    apt-get update && \
    #add-apt-repository "deb https://xpra.org/beta/ groovy main" && \
    #apt-get update && \
    apt-get install --no-install-recommends -y xpra xpra-html5 && \
    apt-get remove -y --purge gnupg wget && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    #mkdir -p /run/user/0/xpra

COPY server/config/xpra.conf /etc/xpra/xpra.conf
COPY server/config/default.png /usr/share/backgrounds/images/default.png

RUN chmod 644 /etc/xpra/ssl-cert.pem \
    # make all applications started with vglrun use video stream encoding
    && echo "\nclass-instance:vglrun=video" >> /etc/xpra/content-type/50_class.conf \
    # create the xpra user and socket directory
    && useradd --create-home --shell /bin/bash xpra --gid xpra --uid 1000 \
    && mkdir -p /run/user/1000/xpra && chown -R 1000 /run/user/1000

WORKDIR /home/xpra

# copy entrypoint script and other scripts used in it
COPY server/config/docker-entrypoint.sh /home/xpra/docker-entrypoint.sh
COPY scripts/check-dri.sh /home/xpra/scripts/check-dri.sh
COPY scripts/fix-video-groups.sh /home/xpra/scripts/fix-video-groups.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
