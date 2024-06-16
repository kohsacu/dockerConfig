FROM alpine:3.20.0

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
  && : "== [debug] packages information; from here ==" \
  && apk --no-cache info \
  && : "== [debug] packages information; up to here ==" \
  && apk --no-cache add \
    openrc \
    openssh \
    shadow \
  && : "== [debug] packages information; from here ==" \
  && apk --no-cache info \
  && : "== [debug] packages information; up to here ==" \
  && rm -f /var/cache/apk/APKINDEX.*.tar.gz \
  && : "== Create Operation User ($ docker run --user=${LOGIN_UID}:${LOGIN_GID}) ==" \
  && groupadd --gid "${LOGIN_GID}" "${LOGIN_USER}" \
  && useradd --create-home --comment "Bastion User" \
    --shell /bin/ash --uid "${LOGIN_UID}" --gid "${LOGIN_GID}" \
    "${LOGIN_USER}" \
  && : "== edit sshd config ==" \
  && mkdir -p "${LOGIN_HOME}/.ssh" \
  && chmod 700 "${LOGIN_HOME}/.ssh" \
  && chown "${LOGIN_UID}:${LOGIN_GID}" "${LOGIN_HOME}/.ssh" \
  && cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.debug \
  && sed -i 's/\(#LogLevel INFO\)/\1\nLogLevel VERBOSE/' /etc/ssh/sshd_config \
  && sed -i 's/^#\(.*HostKey \/etc\/ssh\/ssh_host_ed25519_key\)/\1/' /etc/ssh/sshd_config \
  && sed -i 's/^#\(.*PubkeyAuthentication yes\)/\1/' /etc/ssh/sshd_config \
  && sed -i 's/\(^#PasswordAuthentication yes\)/\1\nPasswordAuthentication no/' /etc/ssh/sshd_config \
  && sed -i 's/^#\(.*PermitEmptyPasswords no\)/\1/' /etc/ssh/sshd_config \
  && sed -i 's/\(^#ChallengeResponseAuthentication yes\)/\1\nChallengeResponseAuthentication no/' /etc/ssh/sshd_config \
  && sed -i '/^AllowTcpForwarding /s/no/yes/' /etc/ssh/sshd_config \
  && { \
    echo -e "\n# == Add sshd Recommended setting =="; \
    echo "Protocol 2"; \
    echo "PermitRootLogin no"; \
  } | tee -a /etc/ssh/sshd_config

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
