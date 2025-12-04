FROM ubuntu:24.04

LABEL maintainer="Kohsacu <24363503+kohsacu@users.noreply.github.com>" \
    local.kohsacu.base.image.source=https://github.com/kohsacu/dockerConfig.git

#USER root

ARG ADD_LOCALE="en_US.UTF-8 UTF-8"
ENV ADD_LOCALE="${ADD_LOCALE}"
ARG SET_LOCALE="en_US.UTF-8"
ENV SET_LOCALE="${SET_LOCALE}"
ENV PATH="$PATH:/root/.local/bin"

ENV DEBIAN_FRONTEND="noninteractive"

# Write it in "1 line 1 package" "alphabetical order" for review.
RUN set -x \
  && mkdir --parents --mode=700 "${HOME}/.ssh" \
  && : LC_ALL=C perl -pi -e \
    's%^deb https?://(?!security)[^ \t]+%deb http://jp.archive.ubuntu.com/ubuntu/%g' \
    /etc/apt/sources.list \
  && apt-get update \
  && apt-get upgrade -y \
  && LC_ALL=C apt-get install -y --no-install-recommends \
    curl \
    expect \
    jq \
    lftp \
    locales \
    netbase \
    nmap \
    openssh-client \
    pipx \
    python3-setuptools \
    sshpass \
    tzdata \
    unzip \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN set -x \
  && pipx install --include-deps \
     ansible==12.2.0 \
     ansible-core==2.19.4 \
     requests \
     urllib3 \
     yq \
     || exit 0 \
  && ansible-galaxy collection install community.general

ARG LC_ALL="en_US.UTF-8"
ENV LC_ALL="${SET_LOCALE}"
ARG LANG="en_US.UTF-8"
ENV LANG="${SET_LOCALE}"
RUN set -x \
  && : "== Add locale ==" \
  && echo "${ADD_LOCALE}" | tee -a /etc/locale.gen \
  && locale-gen "${SET_LOCALE}" \
  && /usr/sbin/update-locale LANG="${SET_LOCALE}" \
  && /usr/sbin/update-locale LC_ALL="${SET_LOCALE}"

#ENTRYPOINT ["ansible"]
CMD ["/bin/bash"]
VOLUME ["/var/opt/ansible"]
WORKDIR "/var/opt/ansible"

