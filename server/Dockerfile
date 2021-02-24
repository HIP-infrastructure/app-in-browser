FROM ubuntu:20.04
LABEL maintainer="nathalie.casati@chuv.ch"

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    software-properties-common wget gnupg xvfb x11-xserver-utils python3-pip && \
    pip3 install pyinotify && \
    wget -q https://xpra.org/gpg.asc -O- | apt-key add - && \
    add-apt-repository "deb https://xpra.org/ focal main" && \
    apt-get update && \
    apt-get install --no-install-recommends -y xpra xpra-html5 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /run/user/0/xpra

COPY install/default.png /usr/share/backgrounds/images/default.png

# pulseaudio lxterminal \
ENTRYPOINT ["xpra", "start", ":80", "--bind-tcp=0.0.0.0:8080", "--html=on", \
 "--mdns=no", "--webcam=no", "--no-daemon", "--start=xhost +"]

# "--start-on-connect=lxterminal", \
