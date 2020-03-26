FROM ubuntu:18.04

LABEL maintainer="Kohsacu <kohsacu@email.local>" \
      local.kohsacu.apps.image.source=https://github.com/kohsacu/dockerConfig.git

ARG SQUID_VERSION="3.5.27"
ENV SQUID_VERSION="${SQUID_VERSION}" \
    SQUID_CACHE_DIR="/var/spool/squid" \
    SQUID_LOG_DIR="/var/log/squid" \
    SQUID_USER="proxy" \
    SQUID_EXTRA_ARGS="${SQUID_EXTRA_ARGS}"

# Write it in "1 line 1 package" "alphabetical order" for review.
RUN set -x \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    squid=${SQUID_VERSION}* \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN set -x \
  && { \
    echo "include /opt/local/etc/squid/*.conf"; \
  } | tee /etc/squid/squid.conf \
  && mkdir --parents --verbose --mode 770 /var/run/squid \
  && chgrp ${SQUID_USER} /var/run/squid

COPY ./entrypoint.sh /sbin/entrypoint.sh
RUN set -x \
  && : "== Add ENTRYPOINT script ==" \
  && chown root. /sbin/entrypoint.sh \
  && chmod 755   /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]
USER ${SQUID_USER}
VOLUME ["/var/spool/squid","/opt/local/etc/init.d","/opt/local/etc/squid"]

