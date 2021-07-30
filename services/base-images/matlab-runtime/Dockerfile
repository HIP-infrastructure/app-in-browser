ARG DAVFS2_VERSION
FROM nc-webdav:${DAVFS2_VERSION}
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG MATLAB_RUNTIME_VERSION
ARG MATLAB_RUNTIME_UPDATE

LABEL base_image_version=${MATLAB_RUNTIME_VERSION}_u${MATLAB_RUNTIME_UPDATE}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y unzip libxt6 wget && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

WORKDIR /base-images/matlab-runtime

RUN mkdir files && \
    wget --no-check-certificate -nv https://ssd.mathworks.com/supportfiles/downloads/${MATLAB_RUNTIME_VERSION}/Release/${MATLAB_RUNTIME_UPDATE}/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_${MATLAB_RUNTIME_VERSION}_Update_${MATLAB_RUNTIME_UPDATE}_glnxa64.zip && \
    unzip -q -d files MATLAB_Runtime_${MATLAB_RUNTIME_VERSION}_Update_${MATLAB_RUNTIME_UPDATE}_glnxa64.zip && \
   ./files/install -agreeToLicense yes -mode silent && \
    rm -rf MATLAB_Runtime_${MATLAB_RUNTIME_VERSION}_Update_${MATLAB_RUNTIME_UPDATE}_glnxa64.zip files

#ENV LD_LIBRARY_PATH /usr/local/MATLAB/MATLAB_Runtime/v98/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v98/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v98/sys/os/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v98/extern/bin/glnxa64:${LD_LIBRARY_PATH}

RUN echo "Done installing Matlab Runtime version ${MATLAB_RUNTIME_VERSION}_u${MATLAB_RUNTIME_UPDATE}"
