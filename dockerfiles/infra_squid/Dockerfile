FROM ubuntu:18.04

LABEL maintainer="Kohsacu"

#USER root

ARG SQUID_VERSION="3.5.27"
ARG SYSLOG_SRV1="192.168.1.2:514"
ENV SQUID_VERSION="${SQUID_VERSION}" \
    SQUID_CACHE_DIR="/var/spool/squid" \
    SQUID_LOG_DIR="/var/log/squid" \
    SQUID_USER="proxy" \
    SYSLOG_SRV1="${SYSLOG_SRV1}"

# Write it in "1 line 1 package" "alphabetical order" for review.
RUN set -x \
  && perl -pi -e \
    's%^deb https?://(?!security)[^ \t]+%deb http://jp.archive.ubuntu.com/ubuntu/%g' \
    /etc/apt/sources.list \
  && apt-get update \
  && apt-get upgrade -y \
  && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
    rsyslog \
    squid=${SQUID_VERSION}* \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN set -x \
  && sed -i -e 's/module(load="imklog"/#module(load="imklog"/' /etc/rsyslog.conf
RUN set -x \
  && { \
    echo "include /opt/local/etc/squid/*.conf"; \
  } | tee /etc/squid/squid.conf

COPY ./require/rsyslog.d/squid/20-transfer.conf /etc/rsyslog.d/20-transfer.conf
RUN set -x \
  && : "== Edit syslog output ==" \
  && sed -i -e "s/%%SYSLOG_SRV1%%/${SYSLOG_SRV1}/" /etc/rsyslog.d/20-transfer.conf

COPY ./common/init.sh /sbin/entrypoint.sh
RUN set -x \
  && : "== Add ENTRYPOINT script ==" \
  && sed -i -e "s:/home/%%LOGIN_USER%%/volume:/opt/local/etc:" /sbin/entrypoint.sh \
  && sed -i -e "s/^exec/#exec/" /sbin/entrypoint.sh \
  && chown root. /sbin/entrypoint.sh \
  && chmod 744   /sbin/entrypoint.sh
ENTRYPOINT ["/sbin/entrypoint.sh"]

VOLUME ["/var/spool/squid","/opt/local/etc/init.d","/opt/local/etc/squid"]

