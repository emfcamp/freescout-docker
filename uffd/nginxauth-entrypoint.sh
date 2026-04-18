#!/usr/bin/env sh

mkdir -p /run/uwsgi/app/uffd-nginxauth
mkdir -p /var/log/uwsgi/app/uffd-nginxauth

exec /usr/bin/supervisord
