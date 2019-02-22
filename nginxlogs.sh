#!/bin/bash
NGINX_BAK_PATH=/var/log/nginx/baklogs/nginx-`date +%F`
NGINX_LOG_PATH=/var/log/nginx
[ -d "$NGINX_BAK_PATH" ] || mkdir -p $NGINX_BAK_PATH
mv ${NGINX_LOG_PATH}/*.log ${NGINX_BAK_PATH}
kill -USR1 `cat /run/nginx.pid`

