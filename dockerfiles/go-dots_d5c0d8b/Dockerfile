FROM ubuntu:16.04

MAINTAINER Kohsacu

USER root

ENV HOME /home/devel
ENV GOPATH ${HOME}/go
ENV PATH ${HOME}/bin:/opt/local/sbin:/opt/local/bin:${PATH}:${GOPATH}/bin:/opt/go/bin

# 作業用ユーザの作成
RUN set -x \
  && : "== Create Operation User ($ docker run --user=1000:1000) ==" \
  && groupadd --gid 1000 devel \
  && useradd --create-home --comment "Operation User" \
    --shell /bin/bash --uid 1000 --gid 1000 \
    --password $(perl -e 'print crypt("devel!1234", "\$6\$sAlT9876\$");') \
    devel \
  && gpasswd -a devel sudo \
  && : "== Make Working diractory ==" \
  && mkdir -p ${HOME}/Work  \
  && mkdir -p ${HOME}/bin \
  && mkdir -p ${HOME}/git-local \
  && mkdir -p ${HOME}/go \
  && mkdir -p ${HOME}/volume \
  && chown -R devel. ${HOME} \
  && : "== Add PATH ==" \
  && { \
    echo "export PATH=${PATH}"; \
    echo "export GOPATH=${GOPATH}"; \
  } | tee -a ${HOME}/.bashrc

# レビューを考慮して「1行 1パッケージ」「アルファベット順」に記述する事
RUN set -x \
  && perl -pi -e \
    's%^deb https?://(?!security)[^ \t]+%deb http://jp.archive.ubuntu.com/ubuntu/%g' \
    /etc/apt/sources.list \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    bash-completion \
    curl \
    git \
    iproute2 \
    iputils-ping \
    jq \
    openssh-client \
    python3 \
    sudo \
    tcpdump \
    time \
    traceroute \
    vim \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install the Go tools
RUN set -x \
  && : "== golang v1.11.5 ==" \
  && curl -L https://dl.google.com/go/go1.11.5.linux-amd64.tar.gz \
    -o /tmp/go1.11.5.linux-amd64.tar.gz \
  && { \
    echo "ff54aafedff961eb94792487e827515da683d61a5f9482f668008832631e5d25  /tmp/go1.11.5.linux-amd64.tar.gz"; \
  } | tee -a /tmp/go1.11.5.linux-amd64.tar.gz.sha256sum \
  && sha256sum -c /tmp/go1.11.5.linux-amd64.tar.gz.sha256sum \
  && tar -C /opt -zxpf /tmp/go1.11.5.linux-amd64.tar.gz \
  && rm -f /tmp/go1.11.5.linux-amd64.tar.gz

# Install go-dots
## Require packeages
RUN set -x \
  && apt-get update && apt-get install -y \
    autoconf \
    automake \
    build-essential \
    gcc-5 \
    libmysqld-dev \
    libtool \
    make \
    pkgconf \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
#   mysql-server-5.7 \

## Intall openssl 1.1.1
WORKDIR /tmp
RUN set -x \
  && curl -L https://www.openssl.org/source/openssl-1.1.1a.tar.gz \
    -o ./openssl-1.1.1a.tar.gz \
  && curl -L https://www.openssl.org/source/openssl-1.1.1a.tar.gz.sha256 \
    -o ./openssl-1.1.1a.tar.gz.sha256 \
  && { \
    echo "$(cat ./openssl-1.1.1a.tar.gz.sha256)  openssl-1.1.1a.tar.gz"; \
  } | tee -a ./openssl-1.1.1a.tar.gz.sha256sum \
  && sha256sum -c ./openssl-1.1.1a.tar.gz.sha256sum \
  && sudo -u devel tar -C ${HOME}/Work -zxpf ./openssl-1.1.1a.tar.gz \
  && rm -f ./openssl-1.1.1a.tar.gz*
WORKDIR ${HOME}/Work/openssl-1.1.1a
RUN set -x \
  && sudo -u devel ./config --prefix=/opt/local \
  && sudo -u devel make \
  && sudo -u devel make depend \
  && sudo -u devel make test && make install \
  && : "== Add Shared object file PATH ==" \
  && { \
    echo "# Self build openssl"; \
    echo "/opt/local/lib"; \
  } | tee -a /etc/ld.so.conf.d/self-build.conf \
  && ldconfig

## Build gobgp
## * Tag: v1.33
RUN set -x \
  && sudo -E -u devel time /opt/go/bin/go get -u github.com/golang/dep/cmd/dep \
  && sudo -u devel mkdir -p ${GOPATH}/src/github.com/influxdata \
  && sudo -u devel mkdir -p ${GOPATH}/src/github.com/osrg \
  && sudo -u devel mkdir -p ${GOPATH}/src/github.com/obgm
WORKDIR ${GOPATH}/src/github.com/influxdata
RUN set -x \
  && sudo -E -u devel git clone https://github.com/influxdata/influxdb.git
WORKDIR influxdb
RUN set -x \
  && : "== influxdb branch 1.8 ==" \
  && sudo -E -u devel git checkout remotes/origin/1.8
WORKDIR ${GOPATH}/src/github.com/osrg
RUN set -x \
  && sudo -E -u devel git clone https://github.com/osrg/gobgp.git
WORKDIR gobgp
RUN set -x \
  && : "== gobgp v1.33 ==" \
  && sudo -E -u devel git checkout refs/tags/v1.33 \
  && sudo -E -u devel time /opt/go/bin/go get github.com/osrg/gobgp/gobgp \
  && sudo -E -u devel time /opt/go/bin/go get github.com/osrg/gobgp/gobgpd
# && sudo -E -u devel ${GOPATH}/bin/dep ensure

## Build libcoap for go-dots
### * CheckSum: 1365dea39a6129a9b7e8c579537e12ffef1558f6
###   * https://github.com/nttdots/go-dots/blob/55c9a43b2fb008134e352f0593400d061b9f8ab4/README.md
### * CheckSum: 1eadd91366cab46767f26e4d10e005198246eac1
###   * https://github.com/nttdots/go-dots/blob/6028e68940d7380844e2edfb7bcd5398c7c2e074/README.md
WORKDIR ${GOPATH}/src/github.com/obgm
RUN set -x \
  && sudo -u devel git clone https://github.com/obgm/libcoap.git
WORKDIR libcoap
RUN set -x \
  && sudo -u devel git checkout 1eadd91366cab46767f26e4d10e005198246eac1 \
  && sudo -u devel ./autogen.sh \
  && sudo -u devel PKG_CONFIG_LIBDIR="/opt/local/lib/pkgconfig" \
    time ./configure --prefix=/opt/local --disable-documentation --with-openssl \
  && : "== [Debug] Check: go/src/github.com/nttdots/go-dots/libcoap/address.go:7:24: ==" \
  && ls -l ./include/coap2/coap* \
  && time sudo -u devel make \
  && time make install \
  && ldconfig

## Build go-dots
## * Not go get '-u' option
RUN set -x \
  && sudo -u devel \
    CGO_CFLAGS="-I/opt/local/include" \
    CGO_LDFLAGS="-L/opt/local/lib" \
    time /opt/go/bin/go get github.com/nttdots/go-dots/...
WORKDIR ${GOPATH}/src/github.com/nttdots/go-dots/mysql_udf
RUN set -x \
  && sudo -u devel \
    CGO_CFLAGS="-I/opt/local/include" \
    CGO_LDFLAGS="-L/opt/local/lib" \
    time make
#   && make install 

# ==

COPY ./common/init.sh /opt/local/sbin/
RUN set -x \
  && : "== Add ENTRYPOINT script ==" \
  && chown root. /opt/local/sbin/init.sh \
  && chmod 744   /opt/local/sbin/init.sh
ENTRYPOINT ["init.sh"]

VOLUME ["/home/devel/volume"]
USER devel
WORKDIR ${HOME}
