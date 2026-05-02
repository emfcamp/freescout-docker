# The freescout-docker versions are completely divorced from the freescout version
FROM tiredofit/freescout:php8.3-1.17.152

COPY nginx.conf /etc/nginx/sites.available/freescout.conf
COPY php.ini /etc/php83/conf.d/99-freescout-docker.ini

RUN apk add --no-cache patch
WORKDIR /assets/install
COPY patches/0001-Disable-notifying-all-users-when-_we_-send-an-email.patch /assets/install/
RUN patch -p1 < 0001-Disable-notifying-all-users-when-_we_-send-an-email.patch

COPY Modules /assets/modules
