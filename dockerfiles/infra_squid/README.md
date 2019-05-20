# HTTP Proxy コンテナ構築手順

## tl;dr

- HTTP Proxy = Squid
- access_log の取得が目的
- syslog サーバは別途用意すること

## Docker Network の作成

クライアント(Proxy を利用したい端末)が収容されているネットワークに接続可能な Docker network を作成する。
- 192.168.1.0/24: Docker ホスト自身が収容されているネットワーク
- 192.168.1.2: Docker ホスト自身
- br_mgmt0: 既存の Bridge

```
$ sudo docker network create --driver bridge \
> --subnet 192.168.1.0/24 --gateway 192.168.1.2 \
> --opt "com.docker.network.bridge.name"="br_mgmt0" br-mgmt0
6d69ddbd8948bbb94fa3c444346f4d7e2e34f918ea77dbfc29ffabd7cf774404

$ sudo docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
6d69ddbd8948        br-mgmt0            bridge              local # ←(※)
a6e23c938e6c        bridge              bridge              local
5a41f95148fe        host                host                local
fbcd0e9d52f9        none                null                local
```

## Dockerfile

- image の作成

```
$ cd ./dockerfiles
$ REPOSITORY='infra/squid'; TAG='3.5.27-1'
$ echo ${REPOSITORY}:${TAG}
$ time sudo docker build --tag ${REPOSITORY}:${TAG} \
> --file ./infra_squid/Dockerfile .

$ sudo docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
infra/squid         3.5.27-1            3263909cf553        10 seconds ago      286MB
(..snip..)
```

- ファイルの配置

```
$ CONTAINER='squid01'
$ sudo mkdir -p ${HOME}/docker.volume/${CONTAINER}/{init.d,squid.etc,squid.spool}
$ sudo chown -R 1000:1000 ${HOME}/docker.volume/${CONTAINER}
$ cp -ip ./require/10-rsyslog.sh ${HOME}/docker.volume/${CONTAINER}/init.d/
$ cp -ip ./require/50-squid.sh ${HOME}/docker.volume/${CONTAINER}/init.d/
$ cp -ip ./require/squid.conf ${HOME}/docker.volume/${CONTAINER}/squid.etc/
```

## docker-compose

### Install

- PATH の通る場所に

```
$ cd /usr/local/bin
$ sudo curl -L -O https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)
$ sudo curl -L -O https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m).sha256
$ sha256sum -c ./docker-compose-$(uname -s)-$(uname -m).sha256
docker-compose-Linux-x86_64: OK
$ sudo mv -i ./docker-compose-$(uname -s)-$(uname -m) ./docker-compose
$ sudo chmod +x ./docker-compose
```

### docker-compose.yml

- 環境変数

```
$ cd ./infra_squid
$ cp -ip ./.env{.template,}
$ vim ./.env
~
REPOSITORY=infra/squid
SQUID_VERSION=3.5.27
TAG=3.5.27-1
CONTAINER=squid01           # ← コンテナへ付与するホスト名
IPV4_ADDRESS=192.168.1.5    # ← コンテナへ付与する IPアドレス
IPV4_SUBNET=192.168.1.0/24  # ← コンテナが所属するネットワーク(= 作成した Docker Network)
~
:wq
```

- コンテナの起動

```
$ sudo docker-compose up -d
Creating squid01 ... done

$ sudo docker-compose ps
 Name           Command         State   Ports
---------------------------------------------
squid01   /sbin/entrypoint.sh   Up
```

- コンテナの停止

```
$ sudo docker-compose down
Stopping squid01 ... done
Removing squid01 ... done
Network br-mgmt0 is external, skipping
```
