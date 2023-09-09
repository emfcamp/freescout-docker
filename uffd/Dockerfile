FROM debian:bullseye AS base

RUN apt-get update && apt-get install -y curl gnupg2 ca-certificates

COPY sources.list /etc/apt/sources.list.d/cccv.list
RUN curl -fsSL https://packages.cccv.de/docs/cccv-archive-key.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/cccv.gpg
RUN apt-get update

FROM base AS web
RUN apt-get install -y uffd

# Not safe for production use, but means things work on HTTP for
# local development.
RUN echo "SESSION_COOKIE_SECURE=False" >> /etc/uffd/uffd.cfg

COPY entrypoint.sh /usr/local/bin/start-uffd

CMD ["/usr/local/bin/start-uffd"]

FROM base AS ldap
RUN apt-get install -y uffd-ldapd

CMD ["uffd-ldapd"]
