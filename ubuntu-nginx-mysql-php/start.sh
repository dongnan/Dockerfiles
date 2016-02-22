#!/bin/bash

mysqladmin -u root password 123456

# start all the services
/usr/local/bin/supervisord -n
