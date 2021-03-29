FROM vgl-base:2.6.80
LABEL maintainer="nathalie.casati@chuv.ch"

ARG MATLAB_RUNTIME_VERSION

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y unzip libxt6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

WORKDIR /apps/base-images/matlab-runtime

COPY ./base-images/matlab-runtime/${MATLAB_RUNTIME_VERSION}/install/*.zip .

RUN mkdir files && \
    unzip -d files *.zip && \
    ./files/install -agreeToLicense yes -mode silent && \
    rm -rf *.zip files && \
    ln -sf /lib/libstdc++.so.6 /usr/local/MATLAB/MATLAB_Runtime/v98/sys/os/glnxa64/libstdc++.so.6

#ENV LD_LIBRARY_PATH /usr/local/MATLAB/MATLAB_Runtime/v98/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v98/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v98/sys/os/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v98/extern/bin/glnxa64:${LD_LIBRARY_PATH}

RUN echo "Done installing Matlab Runtime version ${MATLAB_RUNTIME_VERSION}"
