FROM tiredofit/freescout:php8.3-1.17.104

COPY nginx.conf /etc/nginx/sites.available/freescout.conf

RUN apk add --no-cache patch
WORKDIR /assets/install
COPY patches/0001-Disable-notifying-all-users-when-_we_-send-an-email.patch /assets/install/
RUN patch -p1 < 0001-Disable-notifying-all-users-when-_we_-send-an-email.patch
