FROM debian:jessie
MAINTAINER leowa@outlook.com
# Based on http://www.panticz.de/Squid-Compile-with-SSL-support-under-Debian-Jessie
# squid configuration to allow connection is based on:
# http://www.squid-cache.org/Doc/config/http_access/
# http://ubuntuforums.org/showthread.php?t=1685730  (need to put lines to correct position: before deny all)

ENV SQUID_VERSION=3.4.8\
    SQUID_CACHE_DIR=/var/spool/squid3 \
    SQUID_LOG_DIR=/var/log/squid3 \
    SQUID_USER=proxy

RUN echo "deb http://ftp.de.debian.org/debian wheezy-backports main" > /etc/apt/sources.list.d/wheezy-backports.list \
 && echo "deb-src http://ftp.de.debian.org/debian wheezy-backports main" >>  /etc/apt/sources.list.d/wheezy-backports.list \
 && apt-get update --fix-missing \
 && apt-get install -y wget openssl devscripts build-essential libssl-dev \
 && apt-get source -y squid3 && apt-get build-dep -y squid3 \
 && rm -rf /var/lib/apt/lists/*
# RUN mv /etc/squid3/squid.conf /etc/squid3/squid.conf.dist

RUN wget -q http://dl.panticz.de/squid/squid3-3.4.8_enable_ssl.diff -O - | patch -p2 squid3-3.4.8/debian/rules \
 && cd squid3-3.4.8 && debuild -us -uc
RUN cd squid3-3.4.8 && make install
COPY squid.conf /etc/squid3/squid.conf
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3128/tcp
VOLUME ["${SQUID_CACHE_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
