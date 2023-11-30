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


private link channel
own private subnet
nat gateway routing it through instances
site-to-site vpn and access ur vpc instances and services
direct connect

connect our vpc and the services
private link establish private connectivity vpcs and services which is hosted on aws or on-premise without exposing data to the internet.

Imagine aws private link there should be private endpoint using which we will be able to talk to services across other accoutns and vpcs and which will not be exposed to the public internet.



private link is not service but its a method where we create specific endpoint which will help us to privatley commnuicate and make use of services in other accounts or vpcs.

we don't have to make use of any internet gateway nat devices, public Ip address to commnicate with services.

important thing is to remember that trafic between your vpc and the services does not leave the amazon network.

private link rember that you need to understand two concepts clearly.

1. vpc endpoint which will help you create elastic network interface with private IP which act as the entry point for the traffic to the service.

2.endpoint service where we create an aws private link powered endpoint service so that service that we want to expose can be availbile for usage.

so one is consumer and other one is producer.

create endpoint at caas team side
create service endpoint on gcp side to securily access the service without using public internet connection.


console
1.create ec2 vm with private subnet
2. create new network load balancer with internal facing and select vpc and private subnet, and next create new target group and link with exisitng ec2 vm. 
3.go to endpoint services - and select network loadbalancer - accept for endpoint - select privcate dns name if you have, create service.
4. wait for endpoint service create, copy the service name, and go to the endpont services, and create endpoint, select catageroy find service by name (use our services which we created in steps number 4), and choose vpc, and verify and create endpoint.
5. go to endpoint services - endpont connection - accept endpoint connection request.
6. copy the  network interfaces id - 



