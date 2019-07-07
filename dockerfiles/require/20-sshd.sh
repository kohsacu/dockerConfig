#!/bin/sh

OPENRC="/run/openrc/softlevel"
HOST_KEY="/etc/ssh/ssh_host_ed25519_key"

test -e ${OPENRC} || echo "== Create openrc softlevel file. =="; touch ${OPENRC}
#test -e ${OPENRC} && /etc/init.d/sshd start
test -e ${HOST_KEY} || echo "== Create ssh host key. =="; ssh-keygen -A
echo "== Starting sshd service. =="; /usr/sbin/sshd -D -e &
