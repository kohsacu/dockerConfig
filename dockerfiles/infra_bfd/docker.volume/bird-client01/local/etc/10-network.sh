#!/bin/sh

DEFAULT_VIA="10.100.1.254"

ip route delete default
ip route add default via "${DEFAULT_VIA}"

