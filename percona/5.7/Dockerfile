# vim:set ft=dockerfile:
FROM debian:jessie

# 替换apt源
COPY sources.list /tmp/sources.list
RUN cp -rf /tmp/sources.list /etc/apt/sources.list

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
COPY my.cnf /etc/mysql/my.cnf
COPY debian.cnf /etc/mysql/debian.cnf
COPY mysql /etc/init.d/mysql
RUN chmod +x /etc/init.d/mysql 

VOLUME ["/data/mysql"]

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["/bin/bash"]
