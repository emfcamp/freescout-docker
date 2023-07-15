FROM debian:bullseye

COPY cccv-archive-key.gpg /etc/apt/trusted.gpg.d/
COPY sources.list /etc/apt/sources.list.d/cccv.list

# Because of course we need to install CA certs.
RUN apt-get update && apt-get install -y ca-certificates
RUN apt-get update && apt-get install -y uffd

# Not safe for production use, but means things work on HTTP for
# local development.
RUN echo "SESSION_COOKIE_SECURE=False" >> /etc/uffd/uffd.cfg

COPY entrypoint.sh /usr/local/bin/start-uffd

CMD ["/usr/local/bin/start-uffd"]
