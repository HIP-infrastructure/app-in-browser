FROM matlab-runtime:R2020a_u6

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y default-jre && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

WORKDIR /app/brainstorm

COPY ./install/*.zip .

RUN mkdir -p ./run/brainstorm_db && \
    unzip -d ./run *.zip && \
    rm -rf *.zip

RUN cd run/brainstorm3/bin/R2020a/ && ./brainstorm3.command /usr/local/MATLAB/MATLAB_Runtime/v98
