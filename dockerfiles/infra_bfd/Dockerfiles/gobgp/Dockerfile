FROM ubuntu:18.04

LABEL maintainer="Kohsacu <kohsacu@email.local>" \
      local.kohsacu.base.image.source=https://github.com/kohsacu/dockerConfig.git

USER root
ARG GO_VERSION="1.12.7"
ARG GO_SHA256_CHECKSUM="66d83bfb5a9ede000e33c6579a91a29e6b101829ad41fffb5c5bb6c900e109d9"
ARG GOBGP_BRANCH="v2.7.0"
ENV HOME="/root"
ENV GO_VERSION="${GO_VERSION}" \
    GO_SHA256_CHECKSUM="${GO_SHA256_CHECKSUM}" \
    GOBGP_BRANCH="${GOBGP_BRANCH}" \
    GOPATH="${HOME}/go"
ENV PATH="/opt/local/sbin:${GOPATH}/bin:/opt/go/bin:${PATH}"
ENV DEBIAN_FRONTEND="noninteractive"

# Write it in "1 line 1 package" "alphabetical order" for review.
RUN set -x \
  && perl -pi -e \
    's%^deb https?://(?!security)[^ \t]+%deb http://jp.archive.ubuntu.com/ubuntu/%g' \
    /etc/apt/sources.list \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates \
    curl \
    git \
    iproute2 \
    iputils-ping \
    jq \
    tcpdump \
    traceroute \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install the Go tools
RUN set -x \
  && : "== Make Working diractory ==" \
  && mkdir -p ${GOPATH} \
  && : "== golang v${GO_VERSION} ==" \
  && curl -L https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz \
    -o /tmp/go${GO_VERSION}.linux-amd64.tar.gz \
  && { \
    echo "${GO_SHA256_CHECKSUM}  /tmp/go${GO_VERSION}.linux-amd64.tar.gz"; \
  } | tee -a /tmp/go${GO_VERSION}.linux-amd64.tar.gz.sha256sum \
  && sha256sum -c /tmp/go${GO_VERSION}.linux-amd64.tar.gz.sha256sum \
  && tar -C /opt -zxpf /tmp/go${GO_VERSION}.linux-amd64.tar.gz \
  && rm -f /tmp/go${GO_VERSION}.linux-amd64.tar.gz*

# Build gobgp
RUN set -x \
  && /opt/go/bin/go get -u github.com/golang/dep/cmd/dep \
  && mkdir -p ${GOPATH}/src/github.com/osrg
WORKDIR ${GOPATH}/src/github.com/osrg
RUN set -x \
  && : "== gobgp ${GOBGP_BRANCH} ==" \
  && git clone --branch ${GOBGP_BRANCH} https://github.com/osrg/gobgp.git
WORKDIR gobgp
RUN set -x \
  && /opt/go/bin/go get github.com/osrg/gobgp/cmd/gobgp \
  && /opt/go/bin/go get github.com/osrg/gobgp/cmd/gobgpd
# && /opt/go/bin/go get github.com/osrg/gobgp/...
# && ${GOPATH}/bin/dep ensure

COPY ./init.sh /opt/local/sbin/
RUN set -x \
  && : "== Add ENTRYPOINT script ==" \
  && chown root. /opt/local/sbin/init.sh \
  && chmod 744   /opt/local/sbin/init.sh \
  && mkdir -p    /opt/local/etc

WORKDIR "/root"
ENTRYPOINT ["init.sh"]
#CMD ["/bin/bash"]

