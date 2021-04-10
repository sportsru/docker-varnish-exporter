FROM golang:1.16-buster
MAINTAINER Mikhail Konyakhin <m.konyakhin@gmail.com>

ENV VARNISH_VERSION 6.0.7-1~buster
ENV PROMETHEUS_VARNISH_EXPORTER_VERSION=1.6

RUN set -ex; \
  apt-get update; \
  apt-get install -y --no-install-recommends gnupg apt-transport-https gzip curl; \
  curl -L https://packagecloud.io/varnishcache/varnish60lts/gpgkey | apt-key add -; \
  echo deb https://packagecloud.io/varnishcache/varnish60lts/debian/ buster main > /etc/apt/sources.list.d/varnish.list; \
  apt-get update; \
  apt-get install -y --no-install-recommends varnish=$VARNISH_VERSION

RUN set -ex; \
  curl -L https://github.com/jonnenauha/prometheus_varnish_exporter/releases/download/${PROMETHEUS_VARNISH_EXPORTER_VERSION}/prometheus_varnish_exporter-${PROMETHEUS_VARNISH_EXPORTER_VERSION}.linux-amd64.tar.gz | tar -xz -C /usr/bin --strip-components 1 \
  && chmod +x /usr/bin/prometheus_varnish_exporter

RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false gnupg gzip curl; \
  rm -rf /var/lib/apt/lists/*

ENTRYPOINT prometheus_varnish_exporter
EXPOSE 9131

