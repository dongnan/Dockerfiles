# vim:set ft=dockerfile:
FROM debian:jessie
MAINTAINER DongNan <dongyh@126.com>

# 替换apt源
#COPY 163.sources.list /etc/apt/sources.list

# 安装openresty
ENV RESTY_VERSION="1.11.2.3" \
    RESTY_LUAROCKS_VERSION="2.3.0" \
    RESTY_OPENSSL_VERSION="1.0.2k" \
    RESTY_PCRE_VERSION="8.39" \
    RESTY_J="4" \
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

# nginx 使用web用户运行
RUN groupadd -r web && useradd -r -g web web
# 1) Install apt dependencies
# 2) Download and untar OpenSSL, PCRE, and OpenResty
# 3) Build OpenResty
# 4) Cleanup
RUN \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $RESTY_DEPS \
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
    && DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove $RESTY_DEPS \
    && rm -rf /var/lib/apt/lists/* \
    && cd /tmp \
    && rm -rf luarocks-${RESTY_LUAROCKS_VERSION} luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz
#
COPY nginx/nginx /etc/init.d/nginx
COPY nginx/upstream.conf ${NGINX_CONF_DIR}/upstream.conf
COPY nginx/nginx.conf ${NGINX_CONF_DIR}/nginx.conf
RUN chmod +x /etc/init.d/nginx && ln -sf ${NGINX_CONF_DIR} $RESTY_NGINX_DIR/conf

# 安装 supervisord
RUN \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends supervisor \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /data/logs/supervisor

# 复制supervisor配置文件
COPY supervisor /etc/supervisor
COPY supervisor/supervisor /etc/init.d/supervisor

VOLUME ["/data", "${NGINX_CONF_DIR}"]
EXPOSE 80

COPY .bashrc /root/.bashrc

CMD ["supervisord","-c","/etc/supervisor/supervisord.conf","-n"]
