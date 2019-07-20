FROM alpine:3.10.1

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
ARG CONTAINER="alpine"
ENV CONTAINER "${CONTAINER}"

ENV HOME /home/"${LOGIN_USER}"
ENV PATH "${HOME}"/bin:/opt/local/sbin:/opt/local/bin:"${PATH}"

# Write it in "1 line 1 package" "alphabetical order" for review.
RUN set -x \
  && : "== [debug] packages information; from here ==" \
  && apk --no-cache info \
  && : "== [debug] packages information; up to here ==" \
  && apk --no-cache add \
    openrc \
    openssh \
    shadow \
    sudo \
  && : "== [debug] packages information; from here ==" \
  && apk --no-cache info \
  && : "== [debug] packages information; up to here ==" \
  && rm -f /var/cache/apk/APKINDEX.*.tar.gz \
  && : "== Create Operation User ($ docker run --user=${LOGIN_UID}:${LOGIN_GID}) ==" \
  && groupadd --gid "${LOGIN_GID}" "${LOGIN_USER}" \
  && useradd --create-home --comment "Operation User" \
    --shell /bin/ash --uid "${LOGIN_UID}" --gid "${LOGIN_GID}" \
    "${LOGIN_USER}" \
  && gpasswd --add "${LOGIN_USER}" wheel \
  && : "== Make Working diractory ==" \
  && mkdir -p "${HOME}/Work"  \
  && mkdir -p "${HOME}/bin" \
  && mkdir -p "${HOME}/git-local" \
  && mkdir -p "${HOME}/volume" \
  && : "== edit sshd config ==" \
  && mkdir -p "${HOME}/.ssh" \
  && chmod 700 "${HOME}/.ssh" \
  && chown -R "${LOGIN_USER}". "${HOME}" \
  && cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.debug \
  && sed -i 's/^#\(.*HostKey \/etc\/ssh\/ssh_host_ed25519_key\)/\1/' /etc/ssh/sshd_config \
  && sed -i 's/^#\(.*PubkeyAuthentication yes\)/\1/' /etc/ssh/sshd_config \
  && sed -i 's/\(^#PasswordAuthentication yes\)/\1\nPasswordAuthentication no/' /etc/ssh/sshd_config \
  && sed -i 's/^#\(.*PermitEmptyPasswords no\)/\1/' /etc/ssh/sshd_config \
  && sed -i 's/\(^#ChallengeResponseAuthentication yes\)/\1\nChallengeResponseAuthentication no/' /etc/ssh/sshd_config \
  && sed -i 's/\(#LogLevel INFO\)/\1\nLogLevel VERBOSE/' /etc/ssh/sshd_config \
  && { \
    echo -e "\n# == Add sshd Recommended setting =="; \
    echo "Protocol 2"; \
    echo "PermitRootLogin no"; \
  } | tee -a /etc/ssh/sshd_config \
  && : "== edit allow sudo ==" \
  && { \
    echo "# Uncomment to allow members of group wheel to execute any command"; \
    echo "%wheel ALL=(ALL) ALL"; \
  } | tee /etc/sudoers.d/10-allow_group_wheel \
  && chmod 440 /etc/sudoers.d/10-allow_group_wheel

## ===========================================================================

COPY ./init.sh /opt/local/sbin/
RUN set -x \
  && : "== rc-update ==" \
  && : touch /run/openrc/softlevel \
  && rc-update add sshd \
  && rc-status \
  && : "== Add ENTRYPOINT script ==" \
  && sed -i -e 's/bash/sh/' /opt/local/sbin/init.sh \
  && sed -i -e "s/%%LOGIN_USER%%/${LOGIN_USER}/" /opt/local/sbin/init.sh \
  && chown root. /opt/local/sbin/init.sh \
  && chmod 744   /opt/local/sbin/init.sh

ENTRYPOINT ["init.sh"]
#CMD ["/bin/sh"]

VOLUME ["${HOME}/volume"]
#USER "${LOGIN_USER}"
WORKDIR "${HOME}"

RUN set -x \
  && : "== Change password | User: [${LOGIN_USER}] ==" \
  && echo "${LOGIN_USER}:${LOGIN_USER_PASSWORD}" | chpasswd \
  && { \
    echo "LOGIN_USER_PASSWORD: ${LOGIN_USER_PASSWORD}"; \
  } | tee -a /root/.docker_secret \
  && chmod 400 /root/.docker_secret
