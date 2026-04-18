FROM debian:trixie AS base

RUN apt-get update && apt-get install -y ca-certificates adduser

COPY sources.list /etc/apt/sources.list.d/uffd.list
COPY apt.pref /etc/apt/preferences.d/uffd.pref
ADD --chmod=644 https://packages.cccv.de/docs/cccv-archive-key.gpg /etc/apt/keyrings/cccv.gpg
ADD --chmod=644 http://emfcamp.github.io/uffd/pubkey.gpg /etc/apt/keyrings/emf-uffd.gpg
RUN apt-get update

FROM base AS web
RUN apt-get install -y uffd

# Not safe for production use, but means things work on HTTP for
# local development.
RUN echo "SESSION_COOKIE_SECURE=False" >> /etc/uffd/uffd.cfg

COPY provision.py /usr/local/bin/provision.py
COPY entrypoint.sh /usr/local/bin/start-uffd

CMD ["/usr/local/bin/start-uffd"]

FROM base AS ldap
RUN apt-get install -y uffd-ldapd ldap-utils

COPY ldapsearch /usr/local/bin/uffd-ldapsearch

CMD ["uffd-ldapd"]

FROM base AS nginxauth
RUN apt-get install -y uffd-nginxauth libnginx-mod-http-headers-more-filter libnginx-mod-http-set-misc uwsgi supervisor
RUN rm /etc/nginx/sites-enabled/* /var/log/nginx/access.log /var/log/nginx/error.log && ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

COPY uffd-nginxauth.cfg /etc/uffd-nginxauth/uffd-nginxauth.cfg
COPY nginxauth-supervisor.conf /etc/supervisor/supervisord.conf
COPY nginxauth-nginx.conf /etc/nginx/sites-enabled/uffd-nginxauth
COPY --chmod=755 nginxauth-entrypoint.sh /usr/local/bin/start-nginxauth

CMD ["/usr/local/bin/start-nginxauth"]
