FROM ubuntu:18.04

LABEL maintainer="Kohsacu <kohsacu@email.local>" \
    local.kohsacu.base.image.source=https://github.com/kohsacu/dockerConfig.git

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
ARG LANG="en_US.UTF-8"
ENV LANG="${SET_LOCALE}"

ENV DEBIAN_FRONTEND="noninteractive"
ENV HOME /home/"${LOGIN_USER}"
ENV PATH "${HOME}"/bin:/opt/local/sbin:/opt/local/bin:"${PATH}"

ENV ANSIBLE_SHELL_DIR="/var/tmp/ansible-shell"
ENV ANSIBLE_SBIN_DIR="/opt/local/sbin"
ENV ANSIBLE_BIN_DIR="/opt/local/bin"
ENV PYTHON_VENV_DIR="/var/opt/vEnv"

RUN set -x \
  && : "== Create Operation User ($ docker run --user=${LOGIN_UID}:${LOGIN_GID}) ==" \
  && groupadd --gid "${LOGIN_GID}" "${LOGIN_USER}" \
  && useradd --create-home --comment "Operation User" \
    --shell /bin/bash --uid "${LOGIN_UID}" --gid "${LOGIN_GID}" \
    --password $(LC_ALL=C perl -e 'print crypt("login_secret", "\$6\$sAlT9876\$");') \
    "${LOGIN_USER}" \
  && gpasswd -a "${LOGIN_USER}" sudo \
  && : "== Make Working diractory ==" \
  && mkdir --parents --mode=700   "${HOME}/.ssh" \
  && chown --quiet "${LOGIN_UID}" "${HOME}/.ssh" \
  && chgrp --quiet "${LOGIN_UID}" "${HOME}/.ssh" \
  && mkdir --parents "${ANSIBLE_SHELL_DIR}" \
  && mkdir --parents "${ANSIBLE_SBIN_DIR}" \
  && mkdir --parents "${ANSIBLE_BIN_DIR}" \
  && mkdir --parents "${PYTHON_VENV_DIR}"

# Write it in "1 line 1 package" "alphabetical order" for review.
RUN set -x \
  && LC_ALL=C perl -pi -e \
    's%^deb https?://(?!security)[^ \t]+%deb http://jp.archive.ubuntu.com/ubuntu/%g' \
    /etc/apt/sources.list \
  && apt-get update \
  && apt-get upgrade -y \
  && LC_ALL=C apt-get install -y --no-install-recommends \
    locales \
    openssh-client \
    python3-pip \
    python3-setuptools \
    python3-venv \
    python3.6 \
    python3.6-dev \
    python3.6-venv \
    sshpass \
    sudo \
    tzdata \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./requirements.txt /root/
WORKDIR "${PYTHON_VENV_DIR}"
RUN set -x \
  && : "== Setup python-vEnv ==" \
  && python3 -m venv ansible \
  && . ansible/bin/activate \
  && pip install --no-cache-dir --upgrade pip setuptools \
  && pip install --no-cache-dir --requirement /root/requirements.txt \
  && ln -s "${PYTHON_VENV_DIR}"/ansible/bin/ansible          ${ANSIBLE_BIN_DIR}/ \
  && ln -s "${PYTHON_VENV_DIR}"/ansible/bin/ansible-playbook ${ANSIBLE_BIN_DIR}/ \
  && deactivate

RUN set -x \
  && : "== Add locale ==" \
  && echo "${ADD_LOCALE}" | tee -a /etc/locale.gen \
  && locale-gen "${SET_LOCALE}" \
  && /usr/sbin/update-locale LANG="${SET_LOCALE}" \
  && /usr/sbin/update-locale LC_ALL="${SET_LOCALE}"

RUN set -x \
  && : "== Change password | User: [${LOGIN_USER}] ==" \
  && echo "${LOGIN_USER}:${LOGIN_USER_PASSWORD}" | chpasswd \
  && { \
    echo "LOGIN_USER_PASSWORD: ${LOGIN_USER_PASSWORD}"; \
    echo "MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}"; \
  } | tee -a /root/.docker_secret \
  && chmod 400 /root/.docker_secret

#ENTRYPOINT ["ansible"]
CMD ["/bin/bash"]
USER "${LOGIN_USER}"
VOLUME ["/var/opt/ansible"]
WORKDIR "/var/opt/ansible"

