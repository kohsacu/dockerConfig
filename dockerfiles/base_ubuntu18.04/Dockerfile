FROM ubuntu:18.04

LABEL maintainer="Kohsacu <kohsacu@email.local>" \
    local.kohsacu.base.image.source=https://github.com/kohsacu/dockerConfig/tree/master/dockerfiles/base_ubuntu18.04

USER root

ARG LOGIN_USER="devel"
ENV LOGIN_USER="${LOGIN_USER}"
ARG LOGIN_UID="1000"
ENV LOGIN_UID="${LOGIN_UID}"
ARG LOGIN_GID="1000"
ENV LOGIN_GID="${LOGIN_GID}"
ARG LOGIN_USER_PASSWORD="login_secret"
ENV LOGIN_USER_PASSWORD="${LOGIN_USER_PASSWORD}"
ARG ADD_LOCALE="en_US.UTF-8 UTF-8"
ENV ADD_LOCALE="${ADD_LOCALE}"
ARG SET_LOCALE="en_US.UTF-8"
ENV SET_LOCALE="${SET_LOCALE}"
ENV LC_ALL="${SET_LOCALE}"

ENV DEBIAN_FRONTEND=noninteractive

ENV HOME /home/"${LOGIN_USER}"
ENV GOPATH "${HOME}"/go
ENV PATH "${HOME}"/bin:/opt/local/sbin:/opt/local/bin:"${PATH}":"${GOPATH}"/bin:/opt/go/bin

# Create Operation User
RUN set -x \
  && : "== Create Operation User ($ docker run --user=${LOGIN_UID}:${LOGIN_GID}) ==" \
  && groupadd --gid "${LOGIN_GID}" "${LOGIN_USER}" \
  && useradd --create-home --comment "Operation User" \
    --shell /bin/bash --uid "${LOGIN_UID}" --gid "${LOGIN_GID}" \
    --password $(LC_ALL=C perl -e 'print crypt("login_secret", "\$6\$sAlT9876\$");') \
    "${LOGIN_USER}" \
  && gpasswd -a "${LOGIN_USER}" sudo \
  && : "== Make Working diractory ==" \
  && mkdir -p "${HOME}"/Work  \
  && mkdir -p "${HOME}"/bin \
  && mkdir -p "${HOME}"/git-local \
  && mkdir -p "${HOME}"/go \
  && mkdir -p "${HOME}"/volume \
  && chown -R "${LOGIN_USER}". "${HOME}" \
  && : "== Add PATH ==" \
  && { \
    echo "export PATH=${PATH}"; \
    echo "export GOPATH=${GOPATH}"; \
  } | tee -a "${HOME}"/.bashrc

# Write it in "1 line 1 package" "alphabetical order" for review.
RUN set -x \
  && LC_ALL=C perl -pi -e \
    's%^deb https?://(?!security)[^ \t]+%deb http://jp.archive.ubuntu.com/ubuntu/%g' \
    /etc/apt/sources.list \
  && apt-get update \
  && apt-get upgrade -y \
  && LC_ALL=C apt-get install -y --no-install-recommends \
    bash-completion \
    curl \
    git \
    iproute2 \
    iputils-ping \
    jq \
    locales \
    openssh-client \
    python3 \
    sudo \
    tcpdump \
    time \
    traceroute \
    vim \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

## ===========================================================================

COPY ./init.sh /opt/local/sbin/
RUN set -x \
  && : "== Add locale ==" \
  && echo "${ADD_LOCALE}" | tee -a /etc/locale.gen \
  && locale-gen "${SET_LOCALE}" \
  && /usr/sbin/update-locale LANG="${SET_LOCALE}" \
  && /usr/sbin/update-locale LC_ALL="${SET_LOCALE}" \
  && : "== Add ENTRYPOINT script ==" \
  && sed -i -e "s/%%LOGIN_USER%%/${LOGIN_USER}/" /opt/local/sbin/init.sh \
  && chown root. /opt/local/sbin/init.sh \
  && chmod 744   /opt/local/sbin/init.sh
ENTRYPOINT ["init.sh"]

VOLUME ["/home/${LOGIN_USER}/volume"]
#USER "${LOGIN_USER}"
WORKDIR "${HOME}"

RUN set -x \
  && : "== Change password | User: [${LOGIN_USER}] ==" \
  && echo "${LOGIN_USER}:${LOGIN_USER_PASSWORD}" | chpasswd \
  && { \
    echo "LOGIN_USER_PASSWORD: ${LOGIN_USER_PASSWORD}"; \
    echo "MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}"; \
  } | tee -a /root/.docker_secret \
  && chmod 400 /root/.docker_secret

