FROM alpine:3.20.1

LABEL maintainer="Kohsacu <kohsacu@email.local>" \
      local.kohsacu.base.image.source=https://github.com/kohsacu/dockerConfig.git

#USER root

ARG LOGIN_UID="1000"
ENV LOGIN_UID "${LOGIN_UID}"
ARG LOGIN_GID="1000"
ENV LOGIN_GID "${LOGIN_GID}"
ARG LOGIN_USER="changeMe"
ENV LOGIN_USER "${LOGIN_USER}"
ARG LOGIN_USER_PASSWORD="login_secret"
ENV LOGIN_USER_PASSWORD "${LOGIN_USER_PASSWORD}"
ENV LOGIN_HOME /home/"${LOGIN_USER}"

# Write it in "1 line 1 package" "alphabetical order" for review.
RUN set -x \
  && apk --no-cache add \
    openrc \
    openssh \
    shadow \
  && rm -f /var/cache/apk/APKINDEX.*.tar.gz \
  && : "== Create Operation User ($ docker run --user=${LOGIN_UID}:${LOGIN_GID}) ==" \
  && groupadd --gid "${LOGIN_GID}" "${LOGIN_USER}" \
  && useradd --create-home --comment "Bastion User" \
    --shell /bin/ash --uid "${LOGIN_UID}" --gid "${LOGIN_GID}" \
    "${LOGIN_USER}" \
  && : "== edit sshd config ==" \
  && mkdir -p /etc/ssh/sshd_config.d \
  && mkdir -p "${LOGIN_HOME}/.ssh" \
  && chmod 700 "${LOGIN_HOME}/.ssh" \
  && chown "${LOGIN_UID}:${LOGIN_GID}" "${LOGIN_HOME}/.ssh" \
  && grep "^Include /etc/ssh/sshd_config.d/\*.conf" /etc/ssh/sshd_config
COPY ./sshd_config.d/bastion.conf /etc/ssh/sshd_config.d/bastion.conf

## ===========================================================================

COPY ./entrypoint.sh /entrypoint.sh
RUN set -x \
  && : "== rc-update ==" \
  && : touch /run/openrc/softlevel \
  && : rc-update add sshd \
  && rc-status \
  && chown root. /entrypoint.sh \
  && chmod 744   /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

#USER "${LOGIN_USER}"
WORKDIR "${LOGIN_HOME}"

RUN set -x \
  && : "== Change password | User: [${LOGIN_USER}] ==" \
  && echo "${LOGIN_USER}:${LOGIN_USER_PASSWORD}" | chpasswd \
  && { \
    echo "LOGIN_USER_PASSWORD: ${LOGIN_USER_PASSWORD}"; \
  } | tee -a /root/.docker_secret \
  && chmod 400 /root/.docker_secret
