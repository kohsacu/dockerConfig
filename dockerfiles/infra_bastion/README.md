# build bastion container

## tl;dr

- ssh 踏み台サーバをコンテナで作成

## コンセプト

スモールスタートで最低限の機能からスタート。
- Alpine Linux を使用して軽量に
- 公開鍵認証でのみログインを許可
- sshログを取得
  - 日時
  - 接続元 IP addr/hostname
  - 接続ユーザ名
  - 取得したログは syslog サーバへ転送

## Component

### 構成図

```
                                                 +---------------+
 ~~~~~~~~~~~~~~               +-----+            |  Docker host  |
(              )              |     |            |  +---------+  |
( The Internet )--(Hi Port)-->+ CPE +--(22)--+-->+  | Bastion |  |
(              )              |     |        |   |  +---------+  |
 ~~~~~~~~~~~~~~               +-----+        |   |               |
                                             |   +---------------+
                                             |
                                             |   +------------+
                                             +---| Other host |--+
                                                 +------------+  |--+
                                                    +------------+  |
                                                       +------------+
```

### Docker Network

- 前提
  - CPE は任意の Hi Port を Bastion コンテナの 22/tcp へ Port Mapping する事が出来る
  - Docker hoｓｔ と Other host は IP リーチャビリティがある
  - Docker hoｓｔ の CPE 側 IF は Linux Bridge にて接続されている(後述 `br_mgmt0`)

- Docker Network の作成
  - 192.168.1.0/24: Docker ホスト自身が収容されているネットワーク
  - 192.168.1.3: Docker ホスト自身
  - br_mgmt0: 既存の Bridge

```bash
$ sudo docker network create --driver bridge \
> --subnet 192.168.1.0/24 --gateway 192.168.1.3 \
> --opt "com.docker.network.bridge.name"="br_mgmt0" br-mgmt0
6d69ddbd8948bbb94fa3c444346f4d7e2e34f918ea77dbfc29ffabd7cf774404

$ sudo docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
6d69ddbd8948        br-mgmt0            bridge              local # ←(※)
a6e23c938e6c        bridge              bridge              local
5a41f95148fe        host                host                local
fbcd0e9d52f9        none                null                local
```

## build

### 事前準備

#### 環境変数

```bash
$ cd ./dockerfiles/infra_bastion
$ cp -ip .env{.template,}
$ vim .env
~
REPOSITORY=infra/bastion
TAG=3.10.1-1
CONTAINER=bastion01
IPV4_ADDRESS=192.168.1.5
IPV4_SUBNET=192.168.1.0/24
LOGIN_UID=1000
LOGIN_GID=1000
LOGIN_USER=alpine
LOGIN_USER_PASSWORD=alpine!1234
~
:wq
```

#### volumes(host)

```bash
$ source ./.env
$ sudo mkdir -p ${HOME}/docker.volume/${CONTAINER}/init.d
$ sudo chown -R ${LOGIN_UID}:${LOGIN_GID} ${HOME}/docker.volume/${CONTAINER}
```

#### 起動スクリプト

```bash
$ cp -ip ../common/10-static-routes.sh ${HOME}/docker.volume/${CONTAINER}/init.d
$ sed -i 's/eth1$/eth0/' ~/docker.volume/${CONTAINER}/init.d/10-static-routes.sh
$ sed -i 's/NEXT-HOP/192.168.1.1/' ~/docker.volume/${CONTAINER}/init.d/10-static-routes.sh
```
```bash
$ cp -ip ../require/20-sshd.sh ${HOME}/docker.volume/${CONTAINER}/init.d
```
```bash
$ cp -ip ../common/init.sh .
$ sed -i 's/bash/sh/' ./init.sh
$ chmod +x ./init.sh
```

#### syslogd

- Example
```bash
$ cat /etc/rsyslog.d/30-docker.conf 
:syslogtag, startswith, "docker/infra/bastion:" /var/log/container-bastion.log
& stop
:syslogtag, startswith, "docker/" /var/log/docker-container.log
& stop
```

### build

```bash
$ sudo docker-compose build
```
```bash
$ sudo docker-compose up -d
$ grep ${CONTAINER} /var/log/container-bastion.log | tail

Starting container init scripts on bastion01...
/opt/local/sbin/init.sh: running /home/alpine/volume/init.d/10-static-routes.sh

/opt/local/sbin/init.sh: running /home/alpine/volume/init.d/20-sshd.sh
/lib/rc/sh/openrc-run.sh: line 100: can't create /sys/fs/cgroup/blkio/tasks: Read-only file system
(..snip..)
/lib/rc/sh/openrc-run.sh: line 100: can't create /sys/fs/cgroup/systemd/tasks: Read-only file system
ssh-keygen: generating new host keys: RSA DSA ECDSA ED25519
 * Starting sshd ... [ ok ]
```

### Connect

- docker exec
```bash
$ sudo docker container exec -it --user=${LOGIN_UID}:${LOGIN_GID} ${CONTAINER} ash
```
- ssh-keygen
```bash
$ SSH_KEY="${HOME}/.ssh/id_ed25519_${LOGIN_USER}.pem"
$ ssh-keygen -m PEM -t ed25519 -C "${LOGIN_USER}@docker-container.local" -P "${LOGIN_USER_PASSWORD}" -f "${SSH_KEY}"
```
- 公開鍵の登録
```bash
$ sudo docker cp ${SSH_KEY}.pub ${CONTAINER}:/home/${LOGIN_USER}/.ssh/authorized_keys
$ sudo docker container exec -it --user=1000:1000 ${CONTAINER} ash -c 'ls -ln .ssh/authorized_keys'
-rw-r--r--    1 1000     1000           105 Jul 14 13:35 .ssh/authorized_keys
$ ssh -l bastion -i ${SSH_KEY} 192.168.1.5
Are you sure you want to continue connecting (yes/no)? yes
Enter passphrase for key '${HOME}/.ssh/id_ed25519.${CONTAINER}_${LOGIN_USER}.pem':
```
- login log
```bash
(..snip..)
Jul 14 18:31:55 docker-host docker/infra/bastion:0.1/bastion01[5427]: Connection from 192.168.1.100 port 48064 on 192.168.1.5 port 22
Jul 14 18:31:55 docker-host docker/infra/bastion:0.1/bastion01[5427]: Accepted key ED25519 SHA256:4CEBs4Z0x/iIOUA3wsvrQ8vpvSXtugCUBQl4XbvPdoQ found at /home/alpine/.ssh/authorized_keys:1
Jul 14 18:31:55 docker-host docker/infra/bastion:0.1/bastion01[5427]: Postponed publickey for alpine from 192.168.1.100 port 48064 ssh2 [preauth]
Jul 14 18:31:59 docker-host docker/infra/bastion:0.1/bastion01[5427]: Accepted key ED25519 SHA256:4CEBs4Z0x/iIOUA3wsvrQ8vpvSXtugCUBQl4XbvPdoQ found at /home/alpine/.ssh/authorized_keys:1
Jul 14 18:31:59 docker-host docker/infra/bastion:0.1/bastion01[5427]: Accepted publickey for alpine from 192.168.1.100 port 48064 ssh2: ED25519 SHA256:4CEBs4Z0x/iIOUA3wsvrQ8vpvSXtugCUBQQ
Jul 14 18:31:59 docker-host docker/infra/bastion:0.1/bastion01[5427]: User child is on pid 17
Jul 14 18:31:59 docker-host docker/infra/bastion:0.1/bastion01[5427]: Starting session: shell on pts/1 for alpine from 192.168.1.100 port 48064 id 0
Jul 14 18:32:05 docker-host docker/infra/bastion:0.1/bastion01[5427]: Close session: user alpine from 192.168.1.100 port 48064 id 0
Jul 14 18:32:05 docker-host docker/infra/bastion:0.1/bastion01[5427]: Received disconnect from 192.168.1.100 port 48064:11: disconnected by user
Jul 14 18:32:05 docker-host docker/infra/bastion:0.1/bastion04[5427]: Disconnected from user alpine 192.168.1.100 port 48064
(..snip..)
```

### Check

```bash
bastion01:~$ ps aux | grep sshd
bastion01:~$ sudo ls -la /root
bastion01:~$ exit
container-host:~$ ssh -l bastion 192.168.1.5
Permission denied (publickey,keyboard-interactive).
```
