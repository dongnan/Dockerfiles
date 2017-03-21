# vim:set ft=dockerfile:
FROM debian:jessie
MAINTAINER DongNan <dongyh@126.com>

# 替换apt源
COPY 163.sources.list /etc/apt/sources.list

# 安装 mysql (percona-5.7)
ENV PERCONA_MAJOR=5.7 \
    PERCONA_VERSION=5.7.17-11-1.jessie \
    GOSU_VERSION=1.7 \
    MYSQL_DATA_DIR=/data/mysql

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

# add gosu for easy step-down from root
RUN set -x \
        && DEBIAN_FRONTEND=noninteractive apt-get update \
        && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates curl \
        #&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
        && curl -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" -o /usr/local/bin/gosu \
        #&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
        && curl -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" -o /usr/local/bin/gosu.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

# install "pwgen" for randomizing passwords
# install "apt-transport-https" for Percona's repo (switched to https-only)
RUN apt-get update && apt-get install -y --no-install-recommends \
		apt-transport-https ca-certificates \
		pwgen

ENV GPG_KEYS \
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
RUN set -ex; \
	export GNUPGHOME="$(mktemp -d)"; \
	for key in $GPG_KEYS; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done; \
	gpg --export $GPG_KEYS > /etc/apt/trusted.gpg.d/percona.gpg; \
	rm -r "$GNUPGHOME"; \
	apt-key list

RUN echo 'deb https://repo.percona.com/apt jessie main' > /etc/apt/sources.list.d/percona.list

# we set debconf keys to make APT a little quieter
RUN { \
            echo percona-server-server-$PERCONA_MAJOR percona-server-server/root_password password 'unused'; \
            echo percona-server-server-$PERCONA_MAJOR percona-server-server/root_password_again password 'unused'; \
        } | debconf-set-selections \    
    && DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        percona-server-server-$PERCONA_MAJOR=$PERCONA_VERSION \
    #&& rm -rf /var/lib/apt/lists/* \
    && rm -rf /etc/apt/sources.list.d/percona.list \
    # purge and re-create /data/mysql with appropriate ownership
    && rm -rf $MYSQL_DATA_DIR && mkdir -p $MYSQL_DATA_DIR \
    && chown -R mysql:mysql $MYSQL_DATA_DIR 

# 复制mysql配置文件
COPY etc/mysql /etc/mysql
COPY init.d/mysql /etc/init.d/mysql
RUN chmod +x /etc/init.d/mysql

# 安装 supervisord
RUN \
    #DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends supervisor \
    && mkdir -p /data/logs/supervisor \
    && rm -rf /var/lib/apt/lists/*

# 复制supervisor配置文件
COPY etc/supervisor /etc/supervisor
COPY init.d/supervisor /etc/init.d/supervisor
RUN chmod +x /etc/init.d/supervisor

VOLUME ["/data/mysql"]
EXPOSE 3306

# 初始化数据库
COPY shell/mysql_init.sh /tmp/mysql_init.sh
RUN \
    chmod +x /tmp/mysql_init.sh \
    && bash /tmp/mysql_init.sh && rm -rf /tmp/mysql_init.sh

COPY .bashrc /root/.bashrc

CMD ["supervisord","-c","/etc/supervisor/supervisord.conf","-n"]
