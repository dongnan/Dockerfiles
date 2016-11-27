# vim:set ft=dockerfile:
FROM debian:jessie
MAINTAINER DongNan <dongyh@126.com>

# 替换apt源
COPY 163.sources.list /etc/apt/sources.list

# 安装 mysql (percona-5.7)
ENV PERCONA_MAJOR=5.7 \
    PERCONA_VERSION=5.7.15-9-1.jessie \
    GOSU_VERSION=1.7 \
    MYSQL_DATA_DIR=/data/mysql
# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql
RUN \
    # add gosu for easy step-down from root
    set -x \
    && DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates wget \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    # install "pwgen" for randomizing passwords
    # install "apt-transport-https" for Percona's repo (switched to https-only)
    && DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        apt-transport-https ca-certificates \
        pwgen \
    && apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys \
    # pub   1024D/CD2EFD2A 2009-12-15
    #       Key fingerprint = 430B DF5C 56E7 C94E 848E  E60C 1C4C BDCD CD2E FD2A
    # uid                  Percona MySQL Development Team <mysql-dev@percona.com>
    # sub   2048g/2D607DAF 2009-12-15
    430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A \
    # pub   4096R/8507EFA5 2016-06-30
    #       Key fingerprint = 4D1B B29D 63D9 8E42 2B21  13B1 9334 A25F 8507 EFA5
    # uid                  Percona MySQL Development Team (Packaging key) <mysql-dev@percona.com>
    # sub   4096R/4CAC6D72 2016-06-30
    4D1BB29D63D98E422B2113B19334A25F8507EFA5 \

    && echo 'deb https://repo.percona.com/apt jessie main' > /etc/apt/sources.list.d/percona.list \

    #we set debconf keys to make APT a little quieter
    && { \
            echo percona-server-server-$PERCONA_MAJOR percona-server-server/root_password password 'unused'; \
            echo percona-server-server-$PERCONA_MAJOR percona-server-server/root_password_again password 'unused'; \
        } | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        percona-server-server-$PERCONA_MAJOR=$PERCONA_VERSION \
    && rm -rf /var/lib/apt/lists/* \
    # purge and re-create /data/mysql with appropriate ownership
    && rm -rf $MYSQL_DATA_DIR && mkdir -p $MYSQL_DATA_DIR \
    && chown -R mysql:mysql $MYSQL_DATA_DIR \
    && DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove \
        apt-transport-https ca-certificates wget pwgen

# 复制mysql配置文件
COPY mysql/my.cnf /etc/mysql/my.cnf
COPY mysql/debian.cnf /etc/mysql/debian.cnf
COPY mysql/mysql /etc/init.d/mysql
RUN chmod +x /etc/init.d/mysql


# 安装openresty
ENV RESTY_VERSION="1.11.2.2" \
    RESTY_LUAROCKS_VERSION="2.3.0" \
    RESTY_OPENSSL_VERSION="1.0.2j" \
    RESTY_PCRE_VERSION="8.39" \
    RESTY_J="1" \
    RESTY_INSTALL_DIR=/opt/app/openresty \
    RESTY_NGINX_DIR=/opt/app/nginx \
    NGINX_CONF_DIR=/etc/nginx \
    NGINX_LOG_DIR=/data/logs/nginx \
    NGINX_PID_PATH=/var/run/nginx.pid
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
    --conf-path=$NGINX_CONF_DIR/nginx.conf \
    --http-log-path=$NGINX_LOG_DIR/access.log \
    --error-log-path=$NGINX_LOG_DIR/error.log \
    --lock-path=$RESTY_NGINX_DIR/nginx.lock \
    --pid-path=$NGINX_PID_PATH \
    --http-client-body-temp-path=$RESTY_NGINX_DIR/temp/body \
    --http-fastcgi-temp-path=$RESTY_NGINX_DIR/temp/fastcgi \
    --http-proxy-temp-path=$RESTY_NGINX_DIR/temp/proxy \
    --with-openssl=/tmp/openssl-${RESTY_OPENSSL_VERSION} \
    --with-pcre=/tmp/pcre-${RESTY_PCRE_VERSION}

# openresty deps
ENV RESTY_DEPS \
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
                zlib1g-dev

# 临时
#COPY ustc.sources.list /etc/apt/sources.list

# nginx 使用web用户运行
RUN groupadd -r web && useradd -r -g web web
# 1) Install apt dependencies
# 2) Download and untar OpenSSL, PCRE, and OpenResty
# 3) Build OpenResty
# 4) Cleanup
RUN \
    DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $RESTY_DEPS \
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
    && mkdir -p $NGINX_LOG_DIR \
    && mkdir -p $RESTY_NGINX_DIR/temp \
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
    && DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove $RESTY_DEPS
        
COPY nginx/nginx /etc/init.d/nginx
COPY nginx/nginx.conf /etc/nginx/nginx.conf
RUN chmod +x /etc/init.d/nginx && ln -sf /etc/nginx $RESTY_NGINX_DIR/conf


# 安装 Redis
ENV REDIS_VERSION=3.2.5 \
    REDIS_INSTALL_DIR=/opt/app/redis
# redis deps
ENV REDIS_DEPS \
                ca-certificates \
                curl \
                gcc \
		libc6-dev \
		make
# 创建 redis 用户
RUN groupadd -r redis && useradd -r -g redis redis
# 编译安装 redis
RUN cd /tmp \
    && rm -rf redis* \
    && curl -fSL http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz -o redis-${REDIS_VERSION}.tar.gz \
    && tar xzvf redis-${REDIS_VERSION}.tar.gz \
    && cd redis-${REDIS_VERSION} \
    && make && make PREFIX=$REDIS_INSTALL_DIR install \
    && rm -rf /tmp/redis* \
    && mkdir -p /data/logs/redis \
    && DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove $REDIS_DEPS
COPY redis/redis /etc/init.d/redis
COPY redis/redis.conf /etc/redis.conf
RUN chmod +x /etc/init.d/redis


# 安装 PHP
ENV PHP_VERSION=5.6.28 \
    PHP_INSTALL_DIR=/opt/app/php \
    PHP_CONF_DIR=/etc/php
# persistent / runtime deps
ENV PHPIZE_DEPS \
		autoconf \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkg-config \
		re2c
# PHP 依赖库
ENV PHP_DEPS \
                ca-certificates curl libedit2 libsqlite3-0 xz-utils \
                libgd3 libgd2-xpm-dev libpcre3 libpcre3-dev libcurl3 \
                libreadline-dev libncurses5-dev libxml2 libxml2-dev\
                openssl libcurl4-openssl-dev libssl-dev libmcrypt-dev \
                libfreetype6-dev libbz2-dev zlib1g-dev
# 编译安装
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
		$PHPIZE_DEPS \
                $PHP_DEPS \
	--no-install-recommends && rm -r /var/lib/apt/lists/*

RUN cd /tmp \
    && curl -fSL http://jp2.php.net/get/php-${PHP_VERSION}.tar.xz/from/this/mirror -o php-${PHP_VERSION}.tar.xz \
    && tar xf php-${PHP_VERSION}.tar.xz && cd php-${PHP_VERSION} \
    && ./configure --prefix=$PHP_INSTALL_DIR \
        --with-config-file-path=$PHP_CONF_DIR \
        --enable-pcntl --enable-fpm --enable-gd-native-ttf \
        --with-freetype-dir --enable-bcmath --enable-sysvmsg \
        --enable-sysvsem --enable-sysvshm --enable-soap \
        --enable-opcache --enable-mysqlnd --enable-exif \
        --enable-sockets --enable-mbstring --enable-zip \
        --disable-ipv6 --disable-cgi --with-gd --with-jpeg-dir \
        --with-openssl --with-png-dir --with-zlib --with-mhash \
        --with-curl --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
    && make -j "$(nproc)" && make install && rm -rf /tmp/php-${PHP_VERSION}*

COPY php56/php-fpm /etc/init.d/php-fpm
COPY php56/php-fpm.conf /etc/php/php-fpm.conf
COPY php56/php.ini /etc/php/php.ini
RUN ln -sf /etc/php $PHP_INSTALL_DIR/etc && chmod +x /etc/init.d/php-fpm


# 安装 gearmand
ENV GEARMAND_VERSION=1.1.12 \
    GEARMAND_INSTALL_DIR=/opt/app/gearmand \
    GEARMAND_DOWNLOAD_URL=https://launchpad.net/gearmand/1.2/1.1.12/+download/gearmand-1.1.12.tar.gz
RUN cd /tmp \
    && curl -fSL $GEARMAND_DOWNLOAD_URL -o gearmand-${GEARMAND_VERSION}.tar.gz \
    && tar zxvf gearmand-${GEARMAND_VERSION}.tar.gz && cd gearmand-${GEARMAND_VERSION} \
    && ./configure --prefix=$GEARMAND_INSTALL_DIR \
        --with-sqlite3=no --disable-libdrizzle --disable-libmemcached \
        --disable-libpq  --with-mysql=no \
    && make && make install \
    && rm -rf /tmp/gearmand-${GEARMAND_VERSION}*

#PHP_EXT_DEPS
#                libgd3 libpcre3 libgearman7 libcurl3 libgd2-xpm-dev \
#                libreadline-dev libncurses5-dev libmemcached-dev libbz2-dev \
#                libpcre3-dev pkg-config openssl libcurl4-openssl-dev libssl-dev zlib1g-dev \
#                libxml2-dev libmcrypt-dev libicu-dev libfreetype6-dev

VOLUME ["/data", "/etc"]

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 80
CMD ["/bin/bash"]
