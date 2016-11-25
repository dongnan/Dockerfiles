# vim:set ft=dockerfile:
FROM debian:jessie
MAINTAINER Dong Nan <hidongnan@gmail.com>

# 替换apt源
COPY 163.sources.list /etc/apt/sources.list

# 安装 mysql (percona-5.7)
# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

# add gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apt-get purge -y --auto-remove ca-certificates wget

# install "pwgen" for randomizing passwords
# install "apt-transport-https" for Percona's repo (switched to https-only)
RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-transport-https ca-certificates \
        pwgen \
    && rm -rf /var/lib/apt/lists/*

RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys \
# pub   1024D/CD2EFD2A 2009-12-15
#       Key fingerprint = 430B DF5C 56E7 C94E 848E  E60C 1C4C BDCD CD2E FD2A
# uid                  Percona MySQL Development Team <mysql-dev@percona.com>
# sub   2048g/2D607DAF 2009-12-15
    430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A \
# pub   4096R/8507EFA5 2016-06-30
#       Key fingerprint = 4D1B B29D 63D9 8E42 2B21  13B1 9334 A25F 8507 EFA5
# uid                  Percona MySQL Development Team (Packaging key) <mysql-dev@percona.com>
# sub   4096R/4CAC6D72 2016-06-30
    4D1BB29D63D98E422B2113B19334A25F8507EFA5

RUN echo 'deb https://repo.percona.com/apt jessie main' > /etc/apt/sources.list.d/percona.list

ENV PERCONA_MAJOR 5.7
ENV PERCONA_VERSION 5.7.15-9-1.jessie

#we set debconf keys to make APT a little quieter
RUN { \
        echo percona-server-server-$PERCONA_MAJOR percona-server-server/root_password password 'unused'; \
        echo percona-server-server-$PERCONA_MAJOR percona-server-server/root_password_again password 'unused'; \
    } | debconf-set-selections \
    && apt-get update \
    && apt-get install -y \
        percona-server-server-$PERCONA_MAJOR=$PERCONA_VERSION \
    && rm -rf /var/lib/apt/lists/* \
    # purge and re-create /data/mysql with appropriate ownership
    && rm -rf /data/mysql && mkdir -p /data/mysql \
    && chown -R mysql:mysql /data/mysql

# 复制mysql配置文件
COPY mysql/my.cnf /etc/mysql/my.cnf
COPY mysql/debian.cnf /etc/mysql/debian.cnf
COPY mysql/mysql /etc/init.d/mysql
RUN chmod +x /etc/init.d/mysql


# 安装openresty
# Docker Build Arguments
ENV RESTY_VERSION "1.11.2.2"
ENV RESTY_LUAROCKS_VERSION "2.3.0"
ENV RESTY_OPENSSL_VERSION "1.0.2j"
ENV RESTY_PCRE_VERSION "8.39"
ENV RESTY_J "1"
ENV RESTY_INSTALL_DIR /opt/app/openresty
ENV RESTY_NGINX_DIR /opt/app/nginx
ENV NGINX_LOG_DIR /data/logs/nginx
ENV RESTY_CONFIG_OPTIONS \
    --with-file-aio \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_geoip_module=dynamic \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module=dynamic \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_xslt_module=dynamic \
    --with-ipv6 \
    --with-mail \
    --with-mail_ssl_module \
    --with-md5-asm \
    --with-pcre-jit \
    --with-sha1-asm \
    --with-stream \
    --with-stream_ssl_module \
    --with-threads

# These are not intended to be user-specified
ENV _RESTY_CONFIG_DEPS  \
    --prefix=$RESTY_INSTALL_DIR \
    --sbin-path=$RESTY_NGINX_DIR/sbin/nginx \
    --conf-path=$RESTY_NGINX_DIR/conf/nginx.conf \
    --http-log-path=$NGINX_LOG_DIR/access.log \
    --error-log-path=$NGINX_LOG_DIR/error.log \
    --lock-path=$RESTY_NGINX_DIR/nginx.lock \
    --pid-path=$RESTY_NGINX_DIR/nginx.pid \
    --http-client-body-temp-path=$RESTY_NGINX_DIR/temp/body \
    --http-fastcgi-temp-path=$RESTY_NGINX_DIR/temp/fastcgi \
    --http-proxy-temp-path=$RESTY_NGINX_DIR/temp/proxy \
    --with-openssl=/tmp/openssl-${RESTY_OPENSSL_VERSION} \
    --with-pcre=/tmp/pcre-${RESTY_PCRE_VERSION}

# 临时
#COPY ustc.sources.list /etc/apt/sources.list

# 1) Install apt dependencies
# 2) Download and untar OpenSSL, PCRE, and OpenResty
# 3) Build OpenResty
# 4) Cleanup
RUN \
    DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        libgd-dev \
        libgeoip-dev \
        libncurses5-dev \
        libperl-dev \
        libreadline-dev \
        libxslt1-dev \
        make \
        perl \
        unzip \
        zlib1g-dev \
    && cd /tmp \
    && curl -fSL https://www.openssl.org/source/openssl-${RESTY_OPENSSL_VERSION}.tar.gz -o openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && curl -fSL https://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${RESTY_PCRE_VERSION}.tar.gz -o pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && curl -fSL https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz -o openresty-${RESTY_VERSION}.tar.gz \
    && tar xzf openresty-${RESTY_VERSION}.tar.gz \
    && cd /tmp/openresty-${RESTY_VERSION} \
    && ./configure -j${RESTY_J} ${_RESTY_CONFIG_DEPS} ${RESTY_CONFIG_OPTIONS} \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install \
    && mkdir -p /data/logs/nginx \
    && mkdir -p $RESTY_NGINX_DIR/temp \
    && mkdir -p $RESTY_NGINX_DIR/logs \
    && useradd web \
    && cd /tmp \
    && rm -rf \
        openssl-${RESTY_OPENSSL_VERSION} \
        openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
        openresty-${RESTY_VERSION}.tar.gz openresty-${RESTY_VERSION} \
        pcre-${RESTY_PCRE_VERSION}.tar.gz pcre-${RESTY_PCRE_VERSION} \
    && curl -fSL http://luarocks.org/releases/luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz -o luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && tar xzf luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && cd luarocks-${RESTY_LUAROCKS_VERSION} \
    && ./configure \
        --prefix=$RESTY_INSTALL_DIR/luajit \
        --with-lua=$RESTY_INSTALL_DIR/luajit \
        --lua-suffix=jit-2.1.0-beta2 \
        --with-lua-include=$RESTY_INSTALL_DIR/luajit/include/luajit-2.1 \
    && make build \
    && make install \
    && cd /tmp \
    && rm -rf luarocks-${RESTY_LUAROCKS_VERSION} luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
COPY nginx/nginx /etc/init.d/nginx
RUN ln -sf $RESTY_NGINX_DIR/conf /etc/nginx

VOLUME ["/data"]

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 80
CMD ["/bin/bash"]
