#!/bin/bash
set -e

# 初始化mysql
DATADIR=/data/mysql
INSTALL_LOCK=$DATADIR/install.lock
# mysql默认密码:123456
MYSQL_ROOT_PASSWORD=123456

if [ ! -f "$INSTALL_LOCK" ]; then
    mkdir -p "$DATADIR"
    echo 'Initializing database'
    mysqld --initialize-insecure
    echo 'Database initialized'
    
    mysqld --skip-networking &  
    pid="$!"
    
    mysql=( mysql --protocol=socket -uroot )

    for i in {30..0}; do
        if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
            break
        fi
        echo 'MySQL init process in progress...'
        sleep 1
    done
    if [ "$i" = 0 ]; then
        echo >&2 'MySQL init process failed.'
        exit 1
    fi

    echo "SET @@SESSION.SQL_LOG_BIN=0; DELETE FROM mysql.user; CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'; GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION; DROP DATABASE IF EXISTS test; FLUSH PRIVILEGES;" | "${mysql[@]}"

    if ! kill -s TERM "$pid" || ! wait "$pid"; then
        echo >&2 'MySQL init process failed.'
        exit 1
    fi

    touch $INSTALL_LOCK
    echo
    echo 'MySQL init process done. Ready for start up.'
    echo
fi

#启动 supervisor
supervisord -c /etc/supervisor/supervisord.conf

exec "$@"
