FROM nginx:1.15

LABEL maintainer "tech@abaranovskaya.com"

ENV \
    HOME=/root \
    GNUPGHOME=/root/.gnupg \
    DEBIAN_FRONTEND=noninteractive \
    NAXSI_VERSION=0.56

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
    gpg2 --keyserver pgp.mit.edu --recv-keys 520A9993A1C052F8 && \
    gpg2 --verify nginx.tar.gz.asc nginx.tar.gz && \
  
    wget https://github.com/nbs-system/naxsi/archive/${NAXSI_VERSION}.tar.gz \
        -O naxsi.tar.gz && \
    wget https://github.com/nbs-system/naxsi/releases/download/untagged-afabfc163946baa8036f/naxsi-${NAXSI_VERSION}.tar.gz.sig \
        -O naxsi.tar.gz.sig && \
    gpg2 --keyserver pgp.mit.edu --recv-keys 251A28DE2685AED4 && \
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
