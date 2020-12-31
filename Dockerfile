FROM ubuntu:20.04

MAINTAINER Trevor Welsby <trevor@welsby.de>

ARG version=1.0.0

#VOLUME /usr/local/lib/GNUstep/SOGo/WebServerResources

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
   && apt-get install -y gnupg2 apache2 mariadb-client \
   && ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
   && apt-get install -y tzdata \
   && dpkg-reconfigure -f noninteractive tzdata \
   && a2enmod proxy \
   && a2enmod proxy_http \
   && a2enmod headers \
   && a2enmod rewrite \
   && service apache2 start \
   && apt-key adv --keyserver keys.gnupg.net --recv-key 0x810273C4 \
   && echo 'deb http://packages.inverse.ca/SOGo/nightly/5/ubuntu/ focal focal' >> /etc/apt/sources.list \
   && apt-get update \
   #&& update-rc.d apache2 defaults \
   && mkdir -p /usr/share/doc/sogo \
   && touch /usr/share/doc/sogo/dummy.sh \
   && apt-get install -y sogo \
   && rm /usr/share/doc/sogo/dummy.sh \
   && apt-get install -y sogo-activesync sope4.9-gdl1-mysql \
   && ln -s /etc/apache2/conf.d/SOGo.conf /etc/apache2/conf-available/SOGo.conf \
   && a2enconf SOGo

EXPOSE 20000

USER root

CMD service memcached start && service apache2 start && su - sogo -s /bin/sh -c "sogod -WONoDetach YES -WOPort 20000 -WOLogFile - -WOPidFile /tmp/sogo.pid"
