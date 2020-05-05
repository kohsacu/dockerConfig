#!/bin/sh

DAEMON="/usr/sbin/keepalived"
CONFIG="/opt/local/etc/keeplalived.conf"

${DAEMON} -f ${CONFIG}

