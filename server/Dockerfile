FROM vgl-base:2.6.80
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    software-properties-common wget gnupg \
    xvfb x11-xserver-utils python3-pip \
    python3-xdg menu-xdg && \
    pip3 install pyinotify && \
    wget -q https://xpra.org/gpg.asc -O- | apt-key add - && \
    add-apt-repository "deb https://xpra.org/ focal main" && \
    apt-get update && \
    #add-apt-repository "deb https://xpra.org/beta/ focal main" && \
    #apt-get update && \
    apt-get install --no-install-recommends -y xpra xpra-html5 && \
    apt-get remove -y --purge gnupg wget && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    #mkdir -p /run/user/0/xpra

COPY config/xpra.conf /etc/xpra/xpra.conf

COPY install/default.png /usr/share/backgrounds/images/default.png

RUN chmod 644 /etc/xpra/ssl-cert.pem && \
    echo "\nclass-instance:vglrun=video" >> /etc/xpra/content-type/50_class.conf && \
    useradd --create-home --shell /bin/bash xpra --gid xpra --uid 1000 && \
    mkdir -p /run/user/1000/xpra && chown -R 1000 /run/user/1000

WORKDIR /home/xpra

COPY config/docker-entrypoint.sh /home/xpra/docker-entrypoint.sh

RUN chmod +x ./docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
