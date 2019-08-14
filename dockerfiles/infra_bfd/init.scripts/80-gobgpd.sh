#!/bin/sh

GOBGPD="/root/go/bin/gobgpd"
CONFIG="/root/go/etc/gobgpd.conf"

${GOBGPD} -f ${CONFIG} &
