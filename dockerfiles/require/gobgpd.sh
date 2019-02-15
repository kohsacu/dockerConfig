#!/bin/bash

GOBGP="/home/devel/go/bin/gobgpd"
CONFIG="/home/devel/volume/gobgpd.conf"

${GOBGP} -f ${CONFIG} &
