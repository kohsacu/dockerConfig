FROM ubuntu:18.04

LABEL maintainer="Kohsacu <kohsacu@email.local>" \
      local.kohsacu.base.image.source=https://github.com/kohsacu/dockerConfig.git

ARG ANSIBLE_VERSION="2.8.1-1ppa~bionic"
ENV ANSIBLE_VERSION="${ANSIBLE_VERSION}"

# Write it in "1 line 1 package" "alphabetical order" for review.
RUN set -x \
  && APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn \
  && DEBIAN_FRONTEND=noninteractive \
  && perl -pi -e \
    's%^deb https?://(?!security)[^ \t]+%deb http://jp.archive.ubuntu.com/ubuntu/%g' \
    /etc/apt/sources.list \
  && apt-get update \
  && : apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
    dirmngr \
    gpg \
    gnupg-agent \
    openssh-client \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 93C4A3FD7BB9C367 \
  && apt-key list \
  && { \
    echo "deb http://ppa.launchpad.net/ansible/ansible-2.8/ubuntu bionic main"; \
    echo "deb-src http://ppa.launchpad.net/ansible/ansible-2.8/ubuntu bionic main"; \
  } | tee /etc/apt/sources.list.d/ansible.list \
  && apt-get update \
  && apt-get install -y \
     ansible="${ANSIBLE_VERSION}" \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["ansible"]
#CMD ["/bin/bash"]

WORKDIR "/var/tmp/ansible"
VOLUME ["/var/tmp/ansible"]

