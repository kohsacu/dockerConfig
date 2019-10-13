# HTTP Proxy コンテナ構築手順

## tl;dr

- HTTP Proxy = Squid
- access_log の取得が目的
- syslog サーバは別途用意すること

## Dockerfile

- image の作成

```bash
$ cp -ip ../common/init.sh .
$ sudo docker-compose build
(..snip..)

Successfully built 7d79775c9929
Successfully tagged infra/squid:3.5.27-1

$ sudo docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
infra/squid         3.5.27-1            7d79775c9929        About a minute ago   231MB
(..snip..)
```

- ファイルの配置

```bash
$ . .env
$ sudo mkdir -p ${HOME}/docker.volume/${CONTAINER}/{init.d,squid.etc,squid.spool}
$ sudo chown -R 1000:1000 ${HOME}/docker.volume/${CONTAINER}
$ cp -ip ./require/10-rsyslog.sh ${HOME}/docker.volume/${CONTAINER}/init.d/
$ cp -ip ./require/50-squid.sh ${HOME}/docker.volume/${CONTAINER}/init.d/
$ cp -ip ./require/squid.conf ${HOME}/docker.volume/${CONTAINER}/squid.etc/
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
$ tail /var/log/container-squid01.access_log
```

- コンテナの停止

```bash
$ sudo docker-compose stop
Stopping squid01 ... done
```
