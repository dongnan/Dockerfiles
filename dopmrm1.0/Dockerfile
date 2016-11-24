FROM debian:8
MAINTAINER Dong Nan <hidongnan@gmail.com>

# 替换apt源
COPY sources.list /tmp/sources.list
RUN cp -rf /tmp/sources.list /etc/apt/sources.list

# 安装依赖
RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
        git-core cmake gawk libmysqlclient-dev libxml2-dev libmcrypt-dev \
        libicu-dev openssl build-essential binutils-dev libcap-dev zlib1g-dev \
        libtbb-dev libonig-dev libpcre3-dev autoconf libtool libcurl4-openssl-dev \
        wget libreadline-dev libncurses5-dev libmemcached-dev libbz2-dev \
        libc-client2007e-dev libgoogle-perftools-dev libcloog-ppl-dev libelf-dev \
        libdwarf-dev libunwind8-dev subversion libtbb2 g++-4.8 gcc-4.8 \
        libjemalloc-dev libc6-dev libmpfr4 libgcc1 binutils libc6 libc-dev-bin \
        libc-bin libgomp1 libstdc++-4.8-dev libstdc++6 libarchive13 cmake-data \
        libacl1 libattr1 g++ cpp gcc make libboost-thread1.55.0 libboost-thread-dev \
        libgd2-xpm-dev pkg-config libboost-system1.55-dev libboost-context1.55-dev \
        libboost-program-options1.55-dev libboost-filesystem1.55-dev \
        libboost-regex1.55-dev libmagickwand-dev libiberty-dev libevent-dev \
        libxslt1-dev libgoogle-glog-dev automake libldap2-dev libkrb5-dev \
        libyaml-dev gperf ocaml-native-compilers libnotify-dev screen htop iftop \
        strace ltrace iptraf screen tmux axel sysstat supervisor libgd3 libpcre3 \
        libgearman7 libcurl3  libxml2 libhiredis-dev uuid-dev libtokyocabinet-dev \
        percona-xtrabackup percona-toolkit \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/include/freetype2 /usr/include/freetype2/freetype

# 安装openresty
ENV OPENRESTY_VERSION 1.11.2.2
ENV OPENRESTY_INSTALL_DIR /opt/app/openresty
ENV OPENRESTY_NGINX_DIR /opt/app/openresty/nginx
RUN mkdir /opt/down \
    && cd /opt/down \
    && wget --no-check-certificate https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz \
    && tar xzvf openresty-${OPENRESTY_VERSION}.tar.gz \
    && cd openresty-${OPENRESTY_VERSION} \
    && ./configure --prefix=$OPENRESTY_INSTALL_DIR --sbin-path=$OPENRESTY_NGINX_DIR/sbin/nginx \
        --conf-path=$OPENRESTY_NGINX_DIR/conf/nginx.conf --http-log-path=/data/logs/nginx/access.log \
        --error-log-path=/data/logs/nginx/error.log --lock-path=$OPENRESTY_NGINX_DIR/nginx.lock \
        --pid-path=$OPENRESTY_NGINX_DIR/nginx.pid --http-client-body-temp-path=$OPENRESTY_NGINX_DIR/temp/body \
        --http-fastcgi-temp-path=$OPENRESTY_NGINX_DIR/temp/fastcgi \
        --http-proxy-temp-path=$OPENRESTY_NGINX_DIR/temp/proxy --with-http_addition_module \
        --with-http_image_filter_module --with-http_ssl_module --with-http_realip_module \
        --with-http_stub_status_module --with-http_sub_module --with-http_gzip_static_module \
        --with-stream --with-stream_ssl_module --with-http_dav_module --with-threads \
        --without-http_uwsgi_module --without-http_scgi_module --without-mail_pop3_module \
        --without-mail_imap_module --without-mail_smtp_module --with-pcre-jit \
    && make && make install \
    && mkdir -p /data/logs/nginx \
    && mkdir -p $OPENRESTY_NGINX_DIR/temp \
    && mkdir -p $OPENRESTY_NGINX_DIR/logs \
    && useradd web \
    && rm /opt/down/*

# 安装
