FROM ubuntu:16.04

MAINTAINER Kohsacu

USER root

# 作業用ユーザの作成 ($ docker run --user=1000:1000)
ENV HOME /home/devel
ENV GOPATH ${HOME}/go
ENV PATH ${HOME}/bin:/opt/go/bin:/opt/local/bin:/opt/local/sbin:${PATH}:${GOPATH}/bin
RUN set -x \
  && groupadd --gid 1000 devel \
  && useradd --create-home --comment "Developer User" \
  --shell /bin/bash --uid 1000 --gid 1000 \
  --password $(perl -e 'print crypt("devel!1234", "\$6\$sAlT9876\$");') \
  devel \
  && gpasswd -a devel sudo \
  && mkdir -p ${HOME}/Work  \
  && mkdir -p ${HOME}/bin \
  && mkdir -p ${HOME}/git-local \
  && mkdir -p ${HOME}/go \
  && mkdir -p ${HOME}/volume \
  && chown -R devel. ${HOME} \
  && echo "export PATH=${PATH}" >> ${HOME}/.bashrc \
  && echo "export GOPATH=${GOPATH}" >> ${HOME}/.bashrc
COPY ./common/static-routes ${HOME}/bin/

# レビューを考慮して「1行 1パッケージ」「アルファベット順」に記述する事
RUN set -x \
  && perl -pi -e \
    's%^deb https?://(?!security)[^ \t]+%deb http://jp.archive.ubuntu.com/ubuntu/%g' \
    /etc/apt/sources.list \
  && apt-get update && apt-get install -y \
  bash-completion \
  curl \
  git \
  iproute2 \
  iputils-ping \
  openssh-client \
  python3 \
  sudo \
  tcpdump \
  traceroute \
  vim \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# go-dots
## Require packeages
RUN set -x \
  && apt-get update && apt-get install -y \
  autoconf \
  build-essential \
  libtool \
  pkgconf \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

## Install go1.9.3
WORKDIR ${HOME}/Work
RUN set -x \
  && sudo -u devel curl -O https://dl.google.com/go/go1.9.3.linux-amd64.tar.gz \
  && tar -C /opt -zxpf go1.9.3.linux-amd64.tar.gz

# Intall openssl 1.1.1
RUN set -x \
  && sudo -u devel curl -O https://www.openssl.org/source/openssl-1.1.1a.tar.gz \
  && sudo -u devel curl -O https://www.openssl.org/source/openssl-1.1.1a.tar.gz.sha256 \
  && sudo -u devel tar zxpf openssl-1.1.1a.tar.gz
WORKDIR ${HOME}/Work/openssl-1.1.1a
RUN set -x \
  && sudo -u devel ./config --prefix=/opt/local \
  && sudo -u devel make \
  && sudo -u devel make depend \
  && sudo -u devel make test && make install \
  && echo '# Self build openssl' >  /etc/ld.so.conf.d/self-build.conf \
  && echo '/opt/local/lib'       >> /etc/ld.so.conf.d/self-build.conf \
  && ldconfig

# Install libcoap
## CheckSum: 1365dea39a6129a9b7e8c579537e12ffef1558f6

# Install go-dots

# Install gobgp

#$ cd $GOPATH/src/github.com/nttdots/go-dots/
#$ make && make install

VOLUME ["/home/devel/volume"]
USER devel
WORKDIR ${HOME}
RUN set -x \
  && rm -rf ${HOME}/Work/openssl-1.1.1a* \
  && rm -rf ${HOME}/Work/go1.9.3.linux-amd64.tar.gz
CMD ["/bin/sh"]
