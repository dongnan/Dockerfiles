# vim:set ft=dockerfile:
FROM debian:jessie
MAINTAINER Dong Nan <hidongnan@gmail.com>

# 替换apt源
COPY sources.list /tmp/sources.list
RUN cp -rf /tmp/sources.list /etc/apt/sources.list

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

RUN mkdir /docker-entrypoint-initdb.d

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
        libyaml-dev gperf ocaml-native-compilers libnotify-dev \
        tmux axel sysstat supervisor libgd3 libpcre3 \
        libgearman7 libcurl3  libxml2 libhiredis-dev uuid-dev libtokyocabinet-dev \
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
    && rm -rf /opt/down/*
COPY nginx/nginx /etc/init.d/nginx


VOLUME ["/data"]

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 80
CMD ["/bin/bash"]
