FROM golang:1.14-stretch
MAINTAINER Mikhail Konyakhin <m.konyakhin@gmail.com>

ENV VARNISH_VERSION 6.3.2-1~stretch
ENV PROMETHEUS_VARNISH_EXPORTER_VERSION=1.5.2

RUN set -ex; \
	fetchDeps=" \
		dirmngr \
		gnupg \
	"; \
	apt-get update; \
	apt-get install -y --no-install-recommends apt-transport-https ca-certificates $fetchDeps; \
	key=920A8A7AA7120A8604BCCD294A42CD6EB810E55D; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver http://ha.pool.sks-keyservers.net/ --recv-keys $key; \
	gpg --batch --export export $key > /etc/apt/trusted.gpg.d/varnish.gpg; \
	gpgconf --kill all; \
	rm -rf $GNUPGHOME; \
	echo deb https://packagecloud.io/varnishcache/varnish63/debian/ stretch main > /etc/apt/sources.list.d/varnish.list; \
	apt-get update; \
	apt-get install -y --no-install-recommends varnish=$VARNISH_VERSION; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $fetchDeps; \
	rm -rf /var/lib/apt/lists/*

RUN set -ex; \
  curl -L https://github.com/jonnenauha/prometheus_varnish_exporter/releases/download/${PROMETHEUS_VARNISH_EXPORTER_VERSION}/prometheus_varnish_exporter-${PROMETHEUS_VARNISH_EXPORTER_VERSION}.linux-amd64.tar.gz | tar -xz -C /usr/bin --strip-components 1 \
  && chmod +x /usr/bin/prometheus_varnish_exporter

ENTRYPOINT prometheus_varnish_exporter
EXPOSE 9131

