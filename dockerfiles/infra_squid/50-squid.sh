#!/bin/bash

set -e

create_log_dir() {
  mkdir -p ${SQUID_LOG_DIR}
  chmod -R 755 ${SQUID_LOG_DIR}
  chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_LOG_DIR}
}

create_cache_dir() {
  mkdir -p ${SQUID_CACHE_DIR}
  chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_CACHE_DIR}
}

create_log_dir
create_cache_dir

# default behaviour is to launch squid
#if [[ ! -d ${SQUID_CACHE_DIR}/00 ]]; then
if [[ ! -d ${SQUID_CACHE_DIR}/worker-0/00 ]]; then
  echo "Initializing cache..."
  $(which squid) -N -f /etc/squid/squid.conf -z
else
  echo "Already exists squid cache dir"
fi

echo "Starting squid..."
# /etc/init.d/squid start
# Usage: squid [-cdhvzCFNRVYX] [-n name] [-s | -l facility] [-f config-file] [-[au] port] [-k signal]
#        -Y        Only return UDP_HIT or UDP_MISS_NOFETCH during fast reload.
#        -C        Do not catch fatal signals.
#        -N        No daemon mode.
#        -d level  Write debugging to stderr also.
#        -s | -l facility
#        -f file   Use given config-file instead of
exec $(which squid) -YCNd 1 -f /etc/squid/squid.conf
#exec $(which squid) -YCNd 1 -f /etc/squid/squid.conf ${SQUID_EXTRA_ARGS}

