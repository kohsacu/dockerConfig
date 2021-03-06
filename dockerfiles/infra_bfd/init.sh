#!/bin/sh

DROPIN_DIR="/opt/local/etc"

# Container starting massages...
echo "Starting container init scripts on $(cat /etc/hostname) ..."

for f in ${DROPIN_DIR}/*; do
    case "${f}" in
        *.sh) echo "$0: running $f"; . "$f" ;;
        *)    echo "$0: ignoring $f" ;;
    esac
echo
done

exec /bin/bash
