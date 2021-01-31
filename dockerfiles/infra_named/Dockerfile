FROM ubuntu:18.04

LABEL maintainer="Kohsacu <24363503+kohsacu@users.noreply.github.com>" \
      local.kohsacu.apps.image.source=https://github.com/kohsacu/dockerConfig.git

ARG NAMED_VERSION="1:9.11.3+dfsg-1ubuntu1.13"
ENV NAMED_VERSION="${NAMED_VERSION}" \
    NAMED_ZONE_DIR="/var/cache/bind" \
    NAMED_USER="bind" \
    DEBIAN_FRONTEND=noninteractive

# Write it in "1 line 1 package" "alphabetical order" for review.
RUN set -x \
  && : "== Add deb packages ==" \
  && apt update \
  && apt upgrade -y \
  && apt install -y \
    bind9=${NAMED_VERSION} \
    bind9utils \
    dnsutils \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./files/entrypoint.sh /
RUN set -x \
  && mkdir --parents --verbose --mode 775 /run/named \
  && chown "${NAMED_USER}:${NAMED_USER}"  /run/named \
  && chown root. /entrypoint.sh \
  && chmod 755   /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
VOLUME ["/etc/bind","/var/cache/bind"]
#USER ${NAMED_USER}

