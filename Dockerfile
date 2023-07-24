#FROM quay.apps.lz-np2.ent-ocp4-useast1.aws.internal.das/an846144ad/buster:latest
FROM docker.io/debian:buster-slim

# Squid image for OpenShift Origin

ARG DO_UPGRADE=
ENV DEBIAN_FRONTEND=noninteractive

LABEL io.k8s.description="Squid Proxy." \
      io.k8s.display-name="Squid Proxy" \
      io.openshift.expose-services="8000:http" \
      io.openshift.tags="squid" \
      io.openshift.non-scalable="true" \
      help="For more information visit https://gitlab.com/synacksynack/opsperator/docker-squid" \
      maintainer="Samuel MARTIN MORO <faust64@gmail.com>" \
      version="4.6-1+deb10u6"

COPY config/* /

RUN set -x \
    && echo deb http://deb.debian.org/debian buster-backports main \
	>/etc/apt/sources.list.d/backports.list \
    && apt-get update \
    && apt-get install -y wget libnss-wrapper dumb-init \
    && if test "$DO_UPGRADE"; then \
	apt-get -y upgrade; \
	apt-get -y dist-upgrade; \
    fi \
    && apt-get install -y --no-install-recommends squid \
    && mv /nocache.acl /squid.conf /etc/squid/ \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man /tmp/* \
    && for d in /var/spool/squid /var/log/squid /etc/squid; \
	do \
	    mkdir -p $d \
	    && chown -R 1001:0 $d \
	    && chmod -R g=u $d; \
	done \
    && chown -R 1001:0 /var/run \
    && chmod -R g=u /var/run \
    && ln -sf /dev/stdout /var/log/squid/access.log \
    && ln -sf /dev/stdout /var/log/squid/store.log \
    && ln -sf /dev/stdout /var/log/squid/cache.log \
    && echo "# Cleaning Up" \
    && apt-get clean \
    && apt-get autoremove --purge -y \
    && rm -rvf /usr/share/man /usr/share/doc /var/lib/apt/lists/* \
    && unset HTTP_PROXY HTTPS_PROXY NO_PROXY DO_UPGRADE http_proxy https_proxy

USER 1001
ENTRYPOINT ["dumb-init","--","/run-squid.sh"]
