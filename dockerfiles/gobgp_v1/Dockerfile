FROM ubuntu:18.04

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
  && : "== Add PATH ==" && { \
      echo "export PATH=${PATH}"; \
      echo "export GOPATH=${GOPATH}"; \
    } | tee -a ${HOME}/.bashrc

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
  && sha256sum /tmp/go1.11.5.linux-amd64.tar.gz \
  && : "== SHA256 Checksum: ff54aafedff961eb94792487e827515da683d61a5f9482f668008832631e5d25 ==" \
  && tar -C /opt -zxpf /tmp/go1.11.5.linux-amd64.tar.gz \
  && rm -f /tmp/go1.11.5.linux-amd64.tar.gz

# Build gobgp
RUN set -x \
  && sudo -E -u devel time /opt/go/bin/go get -u github.com/golang/dep/cmd/dep \
  && sudo -u devel mkdir -p ${GOPATH}/src/github.com/osrg \
  && sudo -u devel mkdir -p ${GOPATH}/src/github.com/influxdata
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

COPY ./common/init.sh /opt/local/sbin/
RUN set -x \
  && : "== Add ENTRYPOINT script ==" \
  && chown root. /opt/local/sbin/init.sh \
  && chmod 744   /opt/local/sbin/init.sh
ENTRYPOINT ["init.sh"]

VOLUME ["/home/devel/volume"]
USER devel
WORKDIR ${HOME}
