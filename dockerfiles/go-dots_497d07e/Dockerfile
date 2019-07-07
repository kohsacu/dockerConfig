FROM ubuntu:16.04

MAINTAINER Kohsacu

USER root

ARG LOGIN_USER='devel'
ENV LOGIN_USER "${LOGIN_USER}"
ARG LOGIN_USER_PASSWORD='login_secret'
ENV LOGIN_USER_PASSWORD "${LOGIN_USER_PASSWORD}"
ARG MYSQL_ROOT_PASSWORD='mysql_secret'
ENV MYSQL_ROOT_PASSWORD "${MYSQL_ROOT_PASSWORD}"

ENV HOME /home/"${LOGIN_USER}"
ENV GOPATH ${HOME}/go
ENV PATH ${HOME}/bin:/opt/local/sbin:/opt/local/bin:${PATH}:${GOPATH}/bin:/opt/go/bin

# 作業用ユーザの作成
RUN set -x \
  && : "== Create Operation User ($ docker run --user=1000:1000) ==" \
  && groupadd --gid 1000 "${LOGIN_USER}" \
  && useradd --create-home --comment "Operation User" \
    --shell /bin/bash --uid 1000 --gid 1000 \
    --password $(perl -e 'print crypt("login_secret", "\$6\$sAlT9876\$");') \
    "${LOGIN_USER}" \
  && gpasswd -a "${LOGIN_USER}" sudo \
  && : "== Make Working diractory ==" \
  && mkdir -p ${HOME}/Work  \
  && mkdir -p ${HOME}/bin \
  && mkdir -p ${HOME}/git-local \
  && mkdir -p ${HOME}/go \
  && mkdir -p ${HOME}/volume \
  && chown -R "${LOGIN_USER}". ${HOME} \
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
  && rm -f /tmp/go1.11.5.linux-amd64.tar.gz*

# Install go-dots
## Require packeages
RUN set -x \
  && { \
    echo "mysql-server-5.7 mysql-server/root_password       password ${MYSQL_ROOT_PASSWORD}" ; \
    echo "mysql-server-5.7 mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}" ; \
  } | debconf-set-selections \
  && apt-get update \
  && apt-get install -y \
    autoconf \
    automake \
    build-essential \
    gcc-5 \
    libgnutls-dev \
    libmysqld-dev \
    libtool \
    make \
    mysql-client-5.7 \
    mysql-server-5.7 \
    pkgconf \
    wget \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

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
  && sudo -u "${LOGIN_USER}" tar -C ${HOME}/Work -zxpf ./openssl-1.1.1a.tar.gz \
  && rm -f ./openssl-1.1.1a.tar.gz*
WORKDIR ${HOME}/Work/openssl-1.1.1a
RUN set -x \
  && sudo -u "${LOGIN_USER}" ./config --prefix=/opt/local \
  && sudo -u "${LOGIN_USER}" make \
  && sudo -u "${LOGIN_USER}" make depend \
  && sudo -u "${LOGIN_USER}" make test && make install \
  && : "== Add Shared object file PATH ==" \
  && { \
    echo "# Self build openssl"; \
    echo "/opt/local/lib"; \
  } | tee -a /etc/ld.so.conf.d/self-build.conf \
  && ldconfig

## Build gobgp
## * Tag: v1.33
RUN set -x \
  && sudo -E -u "${LOGIN_USER}" time /opt/go/bin/go get -u github.com/golang/dep/cmd/dep \
  && sudo -u "${LOGIN_USER}" mkdir -p ${GOPATH}/src/github.com/influxdata \
  && sudo -u "${LOGIN_USER}" mkdir -p ${GOPATH}/src/github.com/osrg \
  && sudo -u "${LOGIN_USER}" mkdir -p ${GOPATH}/src/github.com/obgm \
  && sudo -u "${LOGIN_USER}" mkdir -p ${GOPATH}/src/github.com/nttdots
WORKDIR ${GOPATH}/src/github.com/influxdata
RUN set -x \
  && sudo -E -u "${LOGIN_USER}" git clone https://github.com/influxdata/influxdb.git
WORKDIR influxdb
RUN set -x \
  && : "== influxdb branch 1.8 ==" \
  && sudo -E -u "${LOGIN_USER}" git checkout remotes/origin/1.8
WORKDIR ${GOPATH}/src/github.com/osrg
RUN set -x \
  && sudo -E -u "${LOGIN_USER}" git clone https://github.com/osrg/gobgp.git
WORKDIR gobgp
RUN set -x \
  && : "== gobgp v1.33 ==" \
  && sudo -E -u "${LOGIN_USER}" git checkout refs/tags/v1.33 \
  && sudo -E -u "${LOGIN_USER}" time /opt/go/bin/go get github.com/osrg/gobgp/gobgp \
  && sudo -E -u "${LOGIN_USER}" time /opt/go/bin/go get github.com/osrg/gobgp/gobgpd
# && sudo -E -u "${LOGIN_USER}" ${GOPATH}/bin/dep ensure

## Build libcoap for go-dots
### * CheckSum: 1365dea39a6129a9b7e8c579537e12ffef1558f6
###   * https://github.com/nttdots/go-dots/blob/55c9a43b2fb008134e352f0593400d061b9f8ab4/README.md
### * CheckSum: 1eadd91366cab46767f26e4d10e005198246eac1
###   * https://github.com/nttdots/go-dots/blob/6028e68940d7380844e2edfb7bcd5398c7c2e074/README.md
WORKDIR ${GOPATH}/src/github.com/obgm
RUN set -x \
  && sudo -E -u "${LOGIN_USER}" git clone https://github.com/obgm/libcoap.git
WORKDIR libcoap
RUN set -x \
  && : "== libcoap 1eadd91 ==" \
  && sudo -E -u "${LOGIN_USER}" git checkout 1eadd91366cab46767f26e4d10e005198246eac1 \
  && sudo -u "${LOGIN_USER}" ./autogen.sh \
  && sudo -u "${LOGIN_USER}" PKG_CONFIG_LIBDIR="/opt/local/lib/pkgconfig" \
    time ./configure --prefix=/opt/local --disable-documentation --with-openssl \
  && : "== [Debug] Check: go/src/github.com/nttdots/go-dots/libcoap/address.go:7:24: ==" \
  && ls -l ./include/coap2/coap* \
  && time sudo -u "${LOGIN_USER}" make \
  && time make install \
  && ldconfig

## Build go-dots
## * Not go get '-u' option
# 
## d5c0d8b Merge branch 'develop' of https://github.com/nttdots/dots-go-implementation into masterpublic
## 83db5cb Update README.md up to the newest version of go-dots
## b260adb Merge branch 'handle-signal-channel-control-filtering' of https://github.com/nttdots/dots-go-implementation into develop
## 497d07e Implement Signal Channel Control Filtering #163
## 967a5f6 Fix bad request when PUT ACL with ipv4 or ipv6 destination-network #165
## 409a6ab Merge branch 'handle-interop-ietf103-bugs' of https://github.com/nttdots/dots-go-implementation
## 9d2b252 Fit to latest draft(SignalChannel: draft 26) #161
## f6e14f5 Support Block-wise Transfer option to get all mitigations that are maintained by dots server #126
## 108f1c8 Merge branch 'handle-interop-ietf103-bugs' of https://github.com/nttdots/dots-go-implementation into develop
## 0552d89 Fix Unexpected incoming PDU occurred when send mitigation request to DOTS gateway #151
# 
WORKDIR ${GOPATH}/src/github.com/nttdots
RUN set -x \
  && sudo -E -u "${LOGIN_USER}" git clone https://github.com/nttdots/go-dots
WORKDIR go-dots
RUN set -x \
  && : "== go-dots 497d07e ==" \
  && sudo -E -u "${LOGIN_USER}" git checkout 497d07e050b1cda2c320ca644cf010561fcc84ca \
  && sudo -E -u "${LOGIN_USER}" \
    CGO_CFLAGS="-I/opt/local/include" \
    CGO_LDFLAGS="-L/opt/local/lib" \
    time /opt/go/bin/go get github.com/nttdots/go-dots/...
WORKDIR ${GOPATH}/src/github.com/nttdots/go-dots/mysql_udf
RUN set -x \
  && sudo -u "${LOGIN_USER}" \
    CGO_CFLAGS="-I/opt/local/include" \
    CGO_LDFLAGS="-L/opt/local/lib" \
    time make
#   && make install 

# ==
# https://github.com/docker/for-linux/issues/72
RUN set -x \
  && : "== [Measures]: MySQL does not start with overlay2 ==" \
  && : "#find /var/lib/mysql -type f -exec touch {} \;" \
  && tar -C /var/lib -zcpf /root/mysqld_datadir_1st.tar.gz ./mysql \
  && chown -R mysql:mysql /var/lib/mysql
# ==

COPY ./common/init.sh /opt/local/sbin/
RUN set -x \
  && : "== Add ENTRYPOINT script ==" \
  && sed -i -e "s/%%LOGIN_USER%%/${LOGIN_USER}/" /opt/local/sbin/init.sh \
  && chown root. /opt/local/sbin/init.sh \
  && chmod 744   /opt/local/sbin/init.sh
ENTRYPOINT ["init.sh"]

VOLUME ["/home/${LOGIN_USER}/volume","/var/lib/mysql"]
#USER "${LOGIN_USER}"
WORKDIR ${HOME}

RUN set -x \
  && : "== Change ${LOGIN_USER} password ==" \
  && echo "${LOGIN_USER}:${LOGIN_USER_PASSWORD}" | chpasswd \
  && { \
    echo "LOGIN_USER_PASSWORD: ${LOGIN_USER_PASSWORD}"; \
    echo "MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}"; \
  } | tee -a /root/.docker_secret \
  && chmod 400 /root/.docker_secret
