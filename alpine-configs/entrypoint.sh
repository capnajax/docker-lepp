#!/bin/bash 

/docker-entrypoint.sh

sudo -u postgres postgres --config-file=/usr/local/share/postgresql/postgresql.conf.sample
nginx
php-fpm7
bash
