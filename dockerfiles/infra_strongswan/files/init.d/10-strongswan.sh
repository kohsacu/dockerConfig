#!/bin/sh

/bin/mkdir -p /var/lock/subsys
PIDFILE=/var/run/charon.pid
/usr/sbin/ipsec start --nofork

