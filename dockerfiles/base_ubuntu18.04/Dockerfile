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
    traceroute \
    vim \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./common/init.sh /opt/local/sbin/
RUN set -x \
  && : "== Add ENTRYPOINT script ==" \
  && chown root. /opt/local/sbin/init.sh \
  && chmod 744   /opt/local/sbin/init.sh
ENTRYPOINT ["init.sh"]

VOLUME ["/home/devel/volume"]
USER devel
WORKDIR ${HOME}
