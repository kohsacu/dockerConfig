# HTTP Proxy コンテナ構築手順

## tl;dr

- HTTP Proxy = Squid
- access_log の取得が目的
- syslog サーバは別途用意すること
  - 本 README.md では docker ホストを syslog サーバとしている

## Dockerfile

- ファイルの配置

```bash
$ cp -ip ./.env{.template,}
$ vim .env
$ . .env
$ sudo mkdir -p ${PATH_DOCKER_VOLUME}/${CONTAINER}/{init.d,squid.etc,squid.spool}
$ sudo chown -R 13:13       ${PATH_DOCKER_VOLUME}/${CONTAINER}/squid.spool
$ sudo cp -ip ./50-squid.sh ${PATH_DOCKER_VOLUME}/${CONTAINER}/init.d/
$ sudo cp -ip ./squid.conf  ${PATH_DOCKER_VOLUME}/${CONTAINER}/squid.etc/
```

- rsyslogd(ホスト)
```bash
$ cat ../require/30-docker.conf | sudo tee -a /etc/rsyslog.d/30-docker.conf
:syslogtag, startswith, "docker/local-repo/infra/squid:" /var/log/container-squid.log
& stop
:syslogtag, startswith, "docker/"                        /var/log/docker-container.log
& stop
```
```bash
$ echo '$EscapeControlCharactersOnReceive off' | sudo tee -a /etc/rsyslog.d/90-option.conf
```
```bash
$ sudo vim /etc/logrotate.d/rsyslog
$ sudo systemctl restart rsyslog.service
```

- image の作成

```bash
$ sudo docker-compose build
(..snip..)

Successfully built 7d79775c9929
Successfully tagged infra/squid:3.5.27-1

$ sudo docker image ls
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
infra/squid           3.5.27-1            7d79775c9929        55 seconds ago      163MB
(..snip..)
```

- コンテナの起動

```bash
$ sudo docker-compose up -d
Creating squid01 ... done

$ sudo docker-compose ps
 Name           Command         State           Ports
 --------------------------------------------------------------
 squid01   /sbin/entrypoint.sh   Up      0.0.0.0:3128->3128/tcp
```

```bash
$ curl --proxy <docker host>:3128 https://www.goo.ne.jp
```
```bash
$ tail -F /var/log/container-squid.log
```

- コンテナの停止

```bash
$ sudo docker-compose stop
Stopping squid01 ... done
```
