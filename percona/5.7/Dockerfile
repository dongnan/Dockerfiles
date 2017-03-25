# vim:set ft=dockerfile:
FROM dongnan/debian8-gosu:1.7
MAINTAINER DongNan <dongyh@126.com>

# 安装 mysql (percona-5.7)
# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

ENV PERCONA_MAJOR=5.7 \
    PERCONA_VERSION=5.7.15-9-1.jessie \
    MYSQL_DATA_DIR=/data/mysql

RUN echo 'deb https://repo.percona.com/apt jessie main' > /etc/apt/sources.list.d/percona.list

# we set debconf keys to make APT a little quieter
RUN { \
            echo percona-server-server-$PERCONA_MAJOR percona-server-server/root_password password 'unused'; \
            echo percona-server-server-$PERCONA_MAJOR percona-server-server/root_password_again password 'unused'; \
        } | debconf-set-selections \
    && apt-get update \
    && apt-get install -y percona-server-server-$PERCONA_MAJOR=$PERCONA_VERSION \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /etc/apt/sources.list.d/percona.list \
    # purge and re-create /data/mysql with appropriate ownership
    && rm -rf $MYSQL_DATA_DIR && mkdir -p $MYSQL_DATA_DIR \
    && chown -R mysql:mysql $MYSQL_DATA_DIR 

# 复制mysql配置文件
COPY mysql/my.cnf /etc/mysql/my.cnf
COPY mysql/debian.cnf /etc/mysql/debian.cnf
COPY mysql/mysql /etc/init.d/mysql
RUN chmod +x /etc/init.d/mysql

# 安装 supervisord
RUN \
    #DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends supervisor \
    && mkdir -p /data/logs/supervisor

# 复制supervisor配置文件
COPY supervisor /etc/supervisor
COPY supervisor/supervisor /etc/init.d/supervisor

VOLUME ["/data", "/etc"]
EXPOSE 3306

# 初始化数据库
COPY mysql/mysql_init.sh /tmp/mysql_init.sh
RUN \
    chmod +x /tmp/mysql_init.sh \
    && bash /tmp/mysql_init.sh && rm -rf /tmp/mysql_init.sh

COPY .bashrc /root/.bashrc

CMD ["supervisord","-c","/etc/supervisor/supervisord.conf","-n"]