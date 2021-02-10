FROM nginx:1.19

LABEL maintainer "tech@abaranovskaya.com"

ENV \
    HOME=/root \
    GNUPGHOME=/root/.gnupg \
    DEBIAN_FRONTEND=noninteractive \
    NAXSI_VERSION=1.3

# Install basic packages and build tools
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
      wget \
      gnupg2 dirmngr \
      ca-certificates \
      build-essential \
      libssl-dev \
      libpcre3 \
      libpcre3-dev \
      zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# download and extract sources
RUN NGINX_VERSION=`nginx -V 2>&1 | grep "nginx version" | awk -F/ '{ print $2}'` && \
    cd /tmp && \
    wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
        -O nginx.tar.gz && \
    wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz.asc \
        -O nginx.tar.gz.asc && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg2 --keyserver ha.pool.sks-keyservers.net --recv-keys 520A9993A1C052F8 && \
    gpg2 --verify nginx.tar.gz.asc nginx.tar.gz && \
    wget https://github.com/nbs-system/naxsi/archive/${NAXSI_VERSION}.tar.gz \
        -O naxsi.tar.gz && \
    wget https://github.com/nbs-system/naxsi/releases/download/${NAXSI_VERSION}/naxsi-${NAXSI_VERSION}.tar.gz.asc \
        -O naxsi.tar.gz.sig && \
    gpg2 --keyserver ha.pool.sks-keyservers.net --recv-keys 498C46FF087EDC36E7EAF9D445414A82A9B22D78 && \
    gpg2 --verify naxsi.tar.gz.sig naxsi.tar.gz && \
    tar -xvf nginx.tar.gz && \
    mv nginx-${NGINX_VERSION} nginx && \
    rm nginx.tar.gz && \
    tar -xvf naxsi.tar.gz && \
    mv naxsi-${NAXSI_VERSION} naxsi && \
    rm naxsi.tar.gz && \
    apt-get purge -y gnupg2 dirmngr && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* "$GNUPGHOME" nginx.tar.gz.asc naxsi.tar.gz.sig
    
# configure and build
RUN cd /tmp/nginx && \
    BASE_CONFIGURE_ARGS=`nginx -V 2>&1 | grep "configure arguments" | cut -d " " -f 3-` && \
    /bin/sh -c "./configure --add-module=/tmp/naxsi/naxsi_src ${BASE_CONFIGURE_ARGS}" && \
    make && make install && \
    rm -rf /tmp/nginx*
