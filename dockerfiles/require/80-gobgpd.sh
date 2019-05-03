#!/bin/bash

GOBGPD="/home/devel/go/bin/gobgpd"
CONFIG="/home/devel/volume/gobgpd.conf"

${GOBGPD} -f ${CONFIG} &
