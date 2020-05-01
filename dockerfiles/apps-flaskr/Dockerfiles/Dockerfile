FROM cr.local/prj-id/base/apps-flask:1.1.2-1

LABEL maintainer="Kohsacu <kohsacu@email.local>" \
    local.kohsacu.base.image.source=https://github.com/kohsacu/dockerConfig/tree/master/dockerfiles/base_apps-flask \
    local.kohsacu.apps.image.source=https://github.com/kohsacu/dockerConfig/tree/master/dockerfiles/apps-flaskr

USER root
#
ARG LOGIN_USER="devel"
ENV LOGIN_USER="${LOGIN_USER}"

#ENV DEBIAN_FRONTEND=noninteractive
#ENV HOME="/home/${LOGIN_USER}"
#ENV PATH="${HOME}/bin:/opt/local/sbin:/opt/local/bin:${PATH}"

# Write it in "1 line 1 package" "alphabetical order" for review.
#RUN set -x \
#  && apt-get update \
#  && apt-get upgrade -y \
#  && LC_ALL=C apt-get install -y --no-install-recommends \
#    sqlite3 \
#  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./requirements.txt /root/
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

#COPY ./entrypoint.sh /opt/local/sbin/
#RUN set -x \
#  && : "== Add ENTRYPOINT script ==" \
#  && chown root. /opt/local/sbin/entrypoint.sh \
#  && chmod 755   /opt/local/sbin/entrypoint.sh

#ENTRYPOINT ["entrypoint.sh"]
VOLUME ["/opt/local/etc/init.d","/var/opt/apps"]
USER "${LOGIN_USER}"
WORKDIR "/var/opt/apps"

