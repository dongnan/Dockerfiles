# vim:set ft=dockerfile:
FROM debian:jessie
MAINTAINER DongNan <dongyh@126.com>

# 替换apt源
#COPY 163.sources.list /etc/apt/sources.list

# 创建 php 用户
RUN groupadd -r php && useradd -r -g php php

# PHPIZE 依赖库
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
                libfreetype6-dev libbz2-dev zlib1g-dev libicu-dev

# 安装依赖
RUN \
    #DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ${PHPIZE_DEPS} ${PHP_DEPS} \
    #PHP5.3依赖
    && mkdir /usr/include/freetype2/freetype \
    && ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h

# 安装 hiredis,swoole --enable-async-redis 依赖
ENV HIREDIS_VERSION=0.13.3
ENV HIREDIS_SRC_DIR=hiredis
RUN \
    cd /tmp \
    && rm -rf ${HIREDIS_SRC_DIR}* \
    && curl -fSL https://github.com/redis/hiredis/archive/v${HIREDIS_VERSION}.tar.gz -o ${HIREDIS_SRC_DIR}-${HIREDIS_VERSION}.tar.gz \
    && tar xzf ${HIREDIS_SRC_DIR}-${HIREDIS_VERSION}.tar.gz \
    && cd ${HIREDIS_SRC_DIR}-${HIREDIS_VERSION} \
    && make -j && make install && ldconfig

# 安装 memcached 依赖
RUN \
    #DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends libmemcached-dev

# 安装 PHP5.6
ENV PHP56_VERSION=5.6.30 \
    PHP56_INSTALL_DIR=/opt/app/php56 \
    PHP56_CONF_DIR=/etc/php56 \
    PHP56_LOG_DIR=/data/logs/php56 \
    PHP56_FPM_DIR=/etc/init.d/php-fpm-56

# 编译安装
RUN \
    cd /tmp \
    && curl -fSL http://jp2.php.net/get/php-${PHP56_VERSION}.tar.xz/from/this/mirror -o php-${PHP56_VERSION}.tar.xz \
    && tar xf php-${PHP56_VERSION}.tar.xz && cd php-${PHP56_VERSION} \
    && ./configure --prefix=${PHP56_INSTALL_DIR} \
        --with-config-file-path=${PHP56_CONF_DIR} \
        --enable-pcntl --enable-fpm --enable-gd-native-ttf \
        --with-freetype-dir --enable-bcmath --enable-sysvmsg \
        --enable-sysvsem --enable-sysvshm --enable-soap \
        --enable-opcache --enable-mysqlnd --enable-exif \
        --enable-sockets --enable-mbstring --enable-zip \
        --disable-ipv6 --disable-cgi --with-gd --with-jpeg-dir \
        --with-openssl --with-png-dir --with-zlib --with-mhash \
        --with-curl --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
    && make -j "$(nproc)" && make install \
    && rm -rf /tmp/*

RUN mkdir -p ${PHP56_LOG_DIR} \
    && chown php:php -R ${PHP56_LOG_DIR} \
    && mkdir -p ${PHP56_CONF_DIR} \
    && rm -rf ${PHP56_INSTALL_DIR}/etc \
    && cd ${PHP56_INSTALL_DIR} \
    && ln -sf ${PHP56_CONF_DIR} etc

COPY php56/php-fpm-56 ${PHP56_FPM_DIR}
COPY php56/php-fpm.conf ${PHP56_CONF_DIR}/php-fpm.conf
COPY php56/php.ini ${PHP56_CONF_DIR}/php.ini
RUN chmod +x ${PHP56_FPM_DIR}

# 安装 PHP memcache 扩展
ENV PHP_EXT_MEMCACHE=memcache-3.0.8
RUN \
    cd /tmp \
    && rm -rf ${PHP_EXT_MEMCACHE}* \
    && curl -fSL http://pecl.php.net/get/${PHP_EXT_MEMCACHE}.tgz -o ${PHP_EXT_MEMCACHE}.tgz \
    # 安装PHP5.6扩展
    && cd /tmp && tar xzf ${PHP_EXT_MEMCACHE}.tgz \
    && cd ${PHP_EXT_MEMCACHE} \
    && ${PHP56_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP56_INSTALL_DIR}/bin/php-config \
    && make && make install \
    && rm -rf /tmp/${PHP_EXT_MEMCACHE}*

# 安装 PHP memcached 扩展
ENV PHP_EXT_MEMCACHED=memcached-2.2.0
RUN \
    cd /tmp \
    && rm -rf ${PHP_EXT_MEMCACHED}* \
    && curl -fSL http://pecl.php.net/get/${PHP_EXT_MEMCACHED}.tgz -o ${PHP_EXT_MEMCACHED}.tgz \
    # 安装PHP5.6扩展
    && cd /tmp && tar xzf ${PHP_EXT_MEMCACHED}.tgz \
    && cd ${PHP_EXT_MEMCACHED} \
    && ${PHP56_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP56_INSTALL_DIR}/bin/php-config \
    && make && make install \
    && rm -rf /tmp/${PHP_EXT_MEMCACHED}*

# 安装 PHP msgpack 扩展
ENV PHP_EXT_MSGPACK=msgpack-0.5.7
RUN \
    cd /tmp \
    && rm -rf ${PHP_EXT_MSGPACK}* \
    && curl -fSL https://pecl.php.net/get/${PHP_EXT_MSGPACK}.tgz -o ${PHP_EXT_MSGPACK}.tgz \
    # 安装PHP5.6扩展
    && cd /tmp && tar xzf ${PHP_EXT_MSGPACK}.tgz \
    && cd ${PHP_EXT_MSGPACK} \
    && ${PHP56_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP56_INSTALL_DIR}/bin/php-config \
    && make && make install \
    && rm -rf /tmp/${PHP_EXT_MSGPACK}*

# 安装 PHP yar 扩展
ENV PHP_EXT_YAR=yar-1.2.5
RUN \
    cd /tmp \
    && rm -rf ${PHP_EXT_YAR}* \
    && curl -fSL https://pecl.php.net/get/${PHP_EXT_YAR}.tgz -o ${PHP_EXT_YAR}.tgz \
    # 安装PHP5.6扩展
    && cd /tmp && tar xzf ${PHP_EXT_YAR}.tgz \
    && cd ${PHP_EXT_YAR} \
    && ${PHP56_INSTALL_DIR}/bin/phpize \
    && ./configure --enable-msgpack --with-php-config=${PHP56_INSTALL_DIR}/bin/php-config \
    && make && make install \
    && rm -rf /tmp/${PHP_EXT_YAR}*

# 安装 PHP redis 扩展
ENV PHP_EXT_REDIS=redis-3.1.1
RUN \
    cd /tmp \
    && rm -rf ${PHP_EXT_REDIS}* \
    && curl -fSL https://pecl.php.net/get/${PHP_EXT_REDIS}.tgz -o ${PHP_EXT_REDIS}.tgz \
    # 安装PHP5.6扩展
    && cd /tmp && tar xzf ${PHP_EXT_REDIS}.tgz \
    && cd ${PHP_EXT_REDIS} \
    && ${PHP56_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP56_INSTALL_DIR}/bin/php-config \
    && make && make install \
    && rm -rf /tmp/${PHP_EXT_REDIS}*

# 安装 PHP SeasLog 扩展
ENV PHP_EXT_SEASLOG=SeasLog-1.6.9
RUN \
    cd /tmp \
    && rm -rf ${PHP_EXT_SEASLOG}* \
    && curl -fSL https://pecl.php.net/get/${PHP_EXT_SEASLOG}.tgz -o ${PHP_EXT_SEASLOG}.tgz \
    # 安装PHP5.6扩展
    && cd /tmp && tar xzf ${PHP_EXT_SEASLOG}.tgz \
    && cd ${PHP_EXT_SEASLOG} \
    && ${PHP56_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP56_INSTALL_DIR}/bin/php-config \
    && make && make install \
    && rm -rf /tmp/${PHP_EXT_SEASLOG}*

# 安装 PHP swoole 扩展
ENV PHP_EXT_SWOOLE=swoole-1.9.9
RUN \
    cd /tmp \
    && rm -rf ${PHP_EXT_SWOOLE}* \
    && curl -fSL https://pecl.php.net/get/${PHP_EXT_SWOOLE}.tgz -o ${PHP_EXT_SWOOLE}.tgz \
    # 安装PHP5.6扩展
    && cd /tmp && tar xzf ${PHP_EXT_SWOOLE}.tgz \
    && cd ${PHP_EXT_SWOOLE} \
    && ${PHP56_INSTALL_DIR}/bin/phpize \
    && ./configure --enable-async-redis --enable-sockets --with-php-config=${PHP56_INSTALL_DIR}/bin/php-config \
    && make && make install \
    && rm -rf /tmp/${PHP_EXT_SWOOLE}*

# 安装 PHP yac 扩展
ENV PHP_EXT_YAC=yac-0.9.2
RUN \
    cd /tmp \
    && rm -rf ${PHP_EXT_YAC}* \
    && curl -fSL https://pecl.php.net/get/${PHP_EXT_YAC}.tgz -o ${PHP_EXT_YAC}.tgz \
    # 安装PHP5.6扩展
    && cd /tmp && tar xzf ${PHP_EXT_YAC}.tgz \
    && cd ${PHP_EXT_YAC} \
    && ${PHP56_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP56_INSTALL_DIR}/bin/php-config \
    && make && make install \
    && rm -rf /tmp/${PHP_EXT_YAC}*

# 安装 PHP yaf 扩展
ENV PHP_EXT_YAF=yaf-2.3.5
RUN \
    cd /tmp \
    && rm -rf ${PHP_EXT_YAF}* \
    && curl -fSL https://pecl.php.net/get/${PHP_EXT_YAF}.tgz -o ${PHP_EXT_YAF}.tgz \
    # 安装PHP5.6扩展
    && cd /tmp && tar xzf ${PHP_EXT_YAF}.tgz \
    && cd ${PHP_EXT_YAF} \
    && ${PHP56_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP56_INSTALL_DIR}/bin/php-config \
    && make && make install \
    && rm -rf /tmp/${PHP_EXT_YAF}*

# 安装 supervisord
RUN \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends supervisor \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /data/logs/supervisor

# 复制supervisor配置文件
COPY supervisor /etc/supervisor
COPY supervisor/supervisor /etc/init.d/supervisor
RUN chmod +x /etc/init.d/supervisor

VOLUME ["/data", "/etc/php56"]

EXPOSE 9056

COPY .bashrc /root/.bashrc

CMD ["supervisord","-c","/etc/supervisor/supervisord.conf","-n"]
