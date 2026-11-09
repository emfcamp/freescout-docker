# The freescout-docker versions are completely divorced from the freescout version
FROM ghcr.io/nfrastack/container-freescout:2.2.24

RUN mkdir -p /etc/nginx/sites.enabled/freescout
COPY fastcgi_params /etc/nginx/sites.enabled/freescout/fastcgi_params

RUN apk add --no-cache patch
WORKDIR /container/data/freescout/install
COPY patches/0001-Disable-notifying-all-users-when-_we_-send-an-email.patch /container/data/freescout/install
RUN patch -p1 < 0001-Disable-notifying-all-users-when-_we_-send-an-email.patch

RUN mkdir -p /data/Modules

COPY Modules /data/modules
COPY plugins /data/modules
