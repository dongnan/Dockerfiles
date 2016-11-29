#!/bin/bash
set -e

#启动 supervisor
supervisord -c /etc/supervisor/supervisord.conf

#启动服务
#/opt/app/gearmand/sbin/gearmand -L 127.0.0.1 -p 4730 -u root -d -l /data/logs/gearmand.log
#/etc/init.d/mysql start
#/etc/init.d/redis start
#/etc/init.d/php-fpm start
#/etc/init.d/nginx start

exec "$@"
