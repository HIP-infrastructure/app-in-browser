FROM matlab-runtime:R2020a_u6
LABEL maintainer="nathalie.casati@chuv.ch"

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

ENV DISPLAY=":80"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y default-jre sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 


#RUN useradd -rm -u 1001 hip-user -G sudo -g root -s /bin/bash \
# && sed -i '/%sudo.*ALL/a %sudo ALL=(ALL) NOPASSWD: ALL' /etc/sudoers

#USER hip-user

WORKDIR /home/hip-user/apps/brainstorm

COPY ./install/*.zip .

RUN mkdir -p ./run/brainstorm_db && \
    unzip -d ./run *.zip && \
    rm -rf *.zip

ENTRYPOINT ["./run/brainstorm3/bin/R2020a/brainstorm3.command", "/usr/local/MATLAB/MATLAB_Runtime/v98"]
