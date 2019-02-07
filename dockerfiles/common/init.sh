#!/bin/bash

DROP_IN_DIR="/home/devel/volume/init.d"

# Container starting massages...
echo "Starting container init scripts on $(cat /etc/hostname) ..."

for f in ${DROP_IN_DIR}/*; do
    case "${f}" in
        *.sh) echo "$0: running $f"; . "$f" ;;
        *)    echo "$0: ignoring $f" ;;
    esac
echo
done

exec /bin/bash
