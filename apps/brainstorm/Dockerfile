FROM matlab-runtime:R2020a_u6
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive

ARG VIRTUALGL_VERSION

ENV DISPLAY=":80"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    wget default-jre sudo libglu1-mesa libegl1-mesa libxv1 && \
    wget -q https://s3.amazonaws.com/virtualgl-pr/dev/linux/virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    rm virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    apt-get remove -y --purge wget && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --create-home --shell /bin/bash hip-user --uid 1000

WORKDIR /home/hip-user/apps/brainstorm

#RUN useradd -rm -u 1001 hip-user -G sudo -g root -s /bin/bash \
# && sed -i '/%sudo.*ALL/a %sudo ALL=(ALL) NOPASSWD: ALL' /etc/sudoers

#USER hip-user

COPY ./install/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

COPY ./install/*.zip .

RUN mkdir -p ./run/brainstorm_db && \
    unzip -d ./run *.zip && \
    rm -rf *.zip

#CMD sleep 100000000
#ENTRYPOINT ["/usr/bin/vglrun", "-d", "/dev/dri/card1", "./run/brainstorm3/bin/R2020a/brainstorm3.command", "/usr/local/MATLAB/MATLAB_Runtime/v98"]

COPY install/docker-entrypoint.sh /home/hip-user/docker-entrypoint.sh

RUN chmod +x /home/hip-user/docker-entrypoint.sh

ENTRYPOINT ["/home/hip-user/docker-entrypoint.sh"]
