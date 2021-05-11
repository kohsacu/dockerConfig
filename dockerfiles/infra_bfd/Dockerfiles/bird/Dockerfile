FROM ubuntu:18.04

LABEL maintainer="Kohsacu <kohsacu@email.local>" \
      local.kohsacu.base.image.source=https://github.com/kohsacu/dockerConfig.git

ARG BIRD_BRANCH="v2.0.5"
ENV BIRD_BRANCH="${BIRD_BRANCH}"
ENV PATH="/opt/bird/sbin:/opt/local/sbin:${PATH}"
ENV DEBIAN_FRONTEND="noninteractive"

# Write it in "1 line 1 package" "alphabetical order" for review.
RUN set -x \
  && perl -pi -e \
    's%^deb https?://(?!security)[^ \t]+%deb http://jp.archive.ubuntu.com/ubuntu/%g' \
    /etc/apt/sources.list \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    binutils \
    bison \
    curl \
    flex \
    git \
    gcc \
    hping3 \
    iperf3 \
    iproute2 \
    iputils-ping \
    keepalived \
    libncurses5-dev \
    libreadline6-dev \
    libtool \
    m4 \
    make \
    python3.6 \
    tcpdump \
    traceroute \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
WORKDIR "/var/tmp/bird"
# not installed ca-certificates package
RUN set -x \
  && git config --global http.sslVerify false \
  && git clone --branch "${BIRD_BRANCH}" https://gitlab.labs.nic.cz/labs/bird.git "${BIRD_BRANCH}"
WORKDIR "/var/tmp/bird/${BIRD_BRANCH}"
RUN set -x \
  && autoreconf \
  && ./configure \
    --prefix=/opt/bird \
    --runstatedir=/run \
  && make \
  && make install

COPY ./init.sh /opt/local/sbin/
RUN set -x \
  && : "== ENTRYPOINT script ==" \
  && chown root. /opt/local/sbin/init.sh \
  && chmod 744   /opt/local/sbin/init.sh \
  && mkdir -p    /opt/local/etc

WORKDIR "/root"
ENTRYPOINT ["init.sh"]
#ENTRYPOINT ["bird","-f"]
#CMD ["/bin/bash"]
