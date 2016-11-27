FROM debian:jessie
MAINTAINER DongNan <dongyh@126.com>

# 替换apt源
COPY 163.sources.list /etc/apt/sources.list

# 安装 gearmand
ENV GEARMAND_VERSION=1.1.12 \
    GEARMAND_INSTALL_DIR=/opt/app/gearmand \
    GEARMAND_DOWNLOAD_URL=https://launchpad.net/gearmand/1.2/1.1.12/+download/gearmand-1.1.12.tar.gz

# 编译依赖库
ENV GEARMAND_BUILD_DEPS \
                ca-certificates \
                curl \
                autoconf \
		pkg-config \
		g++ \
		gcc \
		make
# gearmand deps
ENV GEARMAND_DEPS \
		libc-dev-bin \
                libstdc++-4.8-dev \
                libboost-thread1.55.0 \
                libboost-thread-dev \
                libboost-system1.55-dev \
                libboost-context1.55-dev \
                libboost-program-options1.55-dev \
                libboost-filesystem1.55-dev \
                libboost-regex1.55-dev \
                libevent-dev \
                uuid-dev \
                gperf \
                libgoogle-perftools-dev
# 安装依赖
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $GEARMAND_BUILD_DEPS $GEARMAND_DEPS \
    # 编译安装 gearmand
    && cd /tmp \
    && curl -fSL $GEARMAND_DOWNLOAD_URL -o gearmand-${GEARMAND_VERSION}.tar.gz \
    && tar zxvf gearmand-${GEARMAND_VERSION}.tar.gz && cd gearmand-${GEARMAND_VERSION} \
    && ./configure --prefix=$GEARMAND_INSTALL_DIR \
        --with-sqlite3=no --disable-libdrizzle --disable-libmemcached \
        --disable-libpq  --with-mysql=no \
    #&& DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove $GEARMAND_BUILD_DEPS \
    #&& rm -rf /var/lib/apt/lists/* \
    && make && make install \
    && rm -rf /tmp/gearmand-${GEARMAND_VERSION}*

CMD ["/bin/bash"]
