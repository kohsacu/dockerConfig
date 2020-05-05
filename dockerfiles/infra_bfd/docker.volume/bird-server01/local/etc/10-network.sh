#!/bin/sh

DEFAULT_VIA="100.64.0.4"

ip route delete default
ip route add default via "${DEFAULT_VIA}"

