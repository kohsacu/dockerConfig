FROM ubuntu:18.04

LABEL maintainer="Kohsacu <kohsacu@email.local>" \
    local.kohsacu.base.image.source=https://github.com/kohsacu/dockerConfig/tree/master/dockerfiles/base_apps-flask

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
ARG LC_ALL="en_US.UTF-8"
ENV LC_ALL="${SET_LOCALE}"

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME /home/"${LOGIN_USER}"
ENV PATH "${HOME}"/bin:/opt/local/sbin:/opt/local/bin:"${PATH}"

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
  && chown -R "${LOGIN_USER}". "${HOME}" \
  && mkdir -p "/opt/local/bin" \
  && mkdir -p "/var/opt/apps" \
  && mkdir -p "/var/opt/vEnv"

# Write it in "1 line 1 package" "alphabetical order" for review.
RUN set -x \
  && LC_ALL=C perl -pi -e \
    's%^deb https?://(?!security)[^ \t]+%deb http://jp.archive.ubuntu.com/ubuntu/%g' \
    /etc/apt/sources.list \
  && apt-get update \
  && apt-get upgrade -y \
  && LC_ALL=C apt-get install -y --no-install-recommends \
    curl \
    jq \
    locales \
    python3-pip \
    python3-setuptools \
    python3-venv \
    python3.6 \
    python3.6-venv \
    sudo \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./apps/requirements.txt /root/
WORKDIR "/var/opt/vEnv"
RUN set -x \
  && : "== Setup python-vEnv ==" \
  && python3 -m venv flask \
  && . flask/bin/activate \
  && pip install --no-cache-dir --upgrade pip setuptools \
  && pip install --no-cache-dir --requirement /root/requirements.txt \
  #&& ln -s /var/opt/vEnv/flask/bin/python  /opt/local/bin/ \
  #&& ln -s /var/opt/vEnv/flask/bin/python3 /opt/local/bin/ \
  && deactivate

## ===========================================================================

COPY ./entrypoint.sh /opt/local/sbin/
RUN set -x \
  && : "== Add locale ==" \
  && echo "${ADD_LOCALE}" | tee -a /etc/locale.gen \
  && locale-gen "${SET_LOCALE}" \
  && /usr/sbin/update-locale LANG="${SET_LOCALE}" \
  && /usr/sbin/update-locale LC_ALL="${SET_LOCALE}" \
  && : "== Add ENTRYPOINT script ==" \
  && chown root. /opt/local/sbin/entrypoint.sh \
  && chmod 755   /opt/local/sbin/entrypoint.sh

RUN set -x \
  && : "== Change password | User: [${LOGIN_USER}] ==" \
  && echo "${LOGIN_USER}:${LOGIN_USER_PASSWORD}" | chpasswd \
  && { \
    echo "LOGIN_USER_PASSWORD: ${LOGIN_USER_PASSWORD}"; \
    echo "MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}"; \
  } | tee -a /root/.docker_secret \
  && chmod 400 /root/.docker_secret

ENTRYPOINT ["entrypoint.sh"]
VOLUME ["/opt/local/etc/init.d","/var/opt/apps"]
USER "${LOGIN_USER}"
#WORKDIR "${HOME}"
WORKDIR "/var/opt/apps"

