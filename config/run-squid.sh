#!/bin/sh

set -x
if test "`id -u`" -ne 0; then
    echo Setting up nswrapper mapping `id -u` to squid
    pwentry="squid:x:`id -u`:`id -g`:squid:/var/spool/squid:/usr/sbin/nologin"
    if grep ^squid: /etc/passwd >/dev/null 2>&1; then
	sed "s|^squid:.*|$pwentry|" /etc/passwd
    else
	( cat /etc/passwd ; echo "$pwentry" )
    fi >/tmp/squid-passwd
    if grep ^squid: /etc/group >/dev/null 2>&1; then
	sed "s|^squid:.*|squid:x:`id -g`:|" /etc/passwd
    else
	( cat /etc/group ; echo "squid:x:`id -g`:" )
    fi >/tmp/squid-group
    export NSS_WRAPPER_PASSWD=/tmp/squid-passwd
    export NSS_WRAPPER_GROUP=/tmp/squid-group
    export LD_PRELOAD=/usr/lib/libnss_wrapper.so
fi

if ! test -d /var/spool/squid/00; then
    if ! squid -N -f /etc/squid/squid.conf -z; then
	echo ERROR: Failed initializing cache
	exit 1
    fi
fi
exec /usr/sbin/squid -f /etc/squid/squid.conf -NYCd 1
