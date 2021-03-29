FROM matlab-runtime:R2020a_u6
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive

ENV DISPLAY=":80"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    wget default-jre sudo && \
    apt-get remove -y --purge wget && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /apps/brainstorm

COPY ./apps/brainstorm/install/*.zip .

RUN mkdir -p ./run/brainstorm_db && \
    unzip -d ./run *.zip && \
    rm -rf *.zip

# copy entrypoint script and other scripts used in it
COPY ./apps/brainstorm/config/docker-entrypoint.sh docker-entrypoint.sh
COPY ./scripts/check-dri.sh scripts/check-dri.sh
COPY ./scripts/create-user.sh scripts/create-user.sh
COPY ./scripts/fix-video-groups.sh scripts/fix-video-groups.sh
COPY ./scripts/process-healthcheck.sh scripts/process-healthcheck.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
