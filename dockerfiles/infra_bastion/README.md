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
                              +-----+
                              |     |                 +---------------+
 ~~~~~~~~~~~~~~               |     |                 |  Docker host  |
(              )              |     |                 |  +---------+  |
( The Internet )--(Hi Port)-->+ CPE +--(publish)----->+  | Bastion |  |
(              )              |     |                 |  +---------+  |
 ~~~~~~~~~~~~~~               |     +-------------+   |               |
                              |     |             |   +---------------+
                              +-----+             |
                                                  |   +------------+
                                                  +---| Other host |--+
                                                      +------------+  |--+
                                                         +------------+  |
                                                            +------------+
```

### Docker Network

- 前提
  - CPE は任意の Hi Port を Docker host の publish port へ Port Mapping する事が出来る
  - Docker host と Other host は IP リーチャビリティがある

## build

### 事前準備

#### 環境変数

```bash
$ cd ./dockerfiles/infra_bastion
$ cp -ip .env{.template,}
$ vim .env
```

#### network

```bash
$ sudo docker network create \
--driver=bridge \
--subnet=172.19.44.0/24 \
--gateway=172.19.44.1 \
--ipv6 \
--subnet=fdee:abcd:172:19:44::/64 \
--gateway=fdee:abcd:172:19:44::1 \
--opt "com.docker.network.bridge.enable_ip_masquerade"=true \
--opt "com.docker.network.bridge.name"="docker_dnat" \
docker_dnat
```
```bash
$ sudo ip6tables --table nat --append PREROUTING --proto tcp --dport ${PUBLIC_SSH} --jump DNAT \
--to [${DNAT_SSH_IPV6}]:22 \
--match comment --comment "${CONTAINER}"
```

#### syslogd

Example:
```bash
$ cat /etc/rsyslog.d/30-docker.conf 
:syslogtag, startswith, "docker/infra/bastion:" /var/log/container-bastion.log
& stop
:syslogtag, startswith, "docker/" /var/log/docker-container.log
& stop
```

### build

```bash
$ sudo docker compose build
```
コンテナに `authorized_keys` を bind mount する都合上 sudo を使用する場合は `-E(--preserve-env)` オプションを付与して下さい。
```bash
$ sudo --preserve-env docker compose up --detach
$ grep ${CONTAINER} /var/log/container-bastion.log | tail
(...snip...)
Jun 15 02:50:31 docker-host docker/infra/bastion:3.20.0-1/bastion01[114696]: == Starting sshd service. ==#015
Jun 15 02:50:31 docker-host docker/infra/bastion:3.20.0-1/bastion01[114696]: + /usr/sbin/sshd -D -e#015
Jun 15 02:50:31 docker-host docker/infra/bastion:3.20.0-1/bastion01[114696]: Server listening on 0.0.0.0 port 22.#015#015
Jun 15 02:50:31 docker-host docker/infra/bastion:3.20.0-1/bastion01[114696]: Server listening on :: port 22.#015#015
```

### Connect

- docker exec
  ```bash
  $ sudo docker container exec -it --user=${LOGIN_UID}:${LOGIN_GID} ${CONTAINER} ash
  $ exit
  ```
- ssh
  ```bash
  $ sudo docker container inspect bastion11 | jq '.[].Mounts[] | select( .Source == "/home/<Docker host User>/.ssh/authorized_keys" )'
  {
    "Type": "bind",
    "Source": "/home/<Docker host User>/.ssh/authorized_keys",
    "Destination": "/home/{{ login_user }}/.ssh/authorized_keys",
    "Mode": "ro",
    "RW": false,
    "Propagation": "rprivate"
  }
  $ sudo docker container exec -it bastion11 sha256sum .ssh/authorized_keys; sha256sum ~/.ssh/authorized_keys
  a76c4c20ba294c08949e95ca990a89fa0a49c5a499a9749b1c3a1ef9c6797c2d  .ssh/authorized_keys
  a76c4c20ba294c08949e95ca990a89fa0a49c5a499a9749b1c3a1ef9c6797c2d  /home/<Docker host User>/.ssh/authorized_keys
  ```
  ```bash
  $ ssh -i ~/.ssh/{{ ssh_private_key }} -l {{ login_user }} -p {{ public_port }} {{ docker_host_ip_address }}
  ```
- login log
  ```bash
  (..snip..)
  Jul 14 18:31:55 docker-host docker/infra/bastion:3.20.0-1/bastion01[114696]: Connection from 192.168.1.100 port 48064 on 172.19.44.22 port 22
  Jul 14 18:31:55 docker-host docker/infra/bastion:3.20.0-1/bastion01[114696]: Accepted key ED25519 SHA256:4CEBs4Z0x/iIOUA3wsvrQ8vpvSXtugCUBQl4XbvPdoQ found at /home/alpine/.ssh/authorized_keys:1
  Jul 14 18:31:55 docker-host docker/infra/bastion:3.20.0-1/bastion01[114696]: Postponed publickey for alpine from 192.168.1.100 port 48064 ssh2 [preauth]
  Jul 14 18:31:59 docker-host docker/infra/bastion:3.20.0-1/bastion01[114696]: Accepted key ED25519 SHA256:4CEBs4Z0x/iIOUA3wsvrQ8vpvSXtugCUBQl4XbvPdoQ found at /home/alpine/.ssh/authorized_keys:1
  Jul 14 18:31:59 docker-host docker/infra/bastion:3.20.0-1/bastion01[114696]: Accepted publickey for alpine from 192.168.1.100 port 48064 ssh2: ED25519 SHA256:4CEBs4Z0x/iIOUA3wsvrQ8vpvSXtugCUBQQ
  Jul 14 18:31:59 docker-host docker/infra/bastion:3.20.0-1/bastion01[114696]: User child is on pid 17
  Jul 14 18:31:59 docker-host docker/infra/bastion:3.20.0-1/bastion01[114696]: Starting session: shell on pts/1 for alpine from 192.168.1.100 port 48064 id 0
  Jul 14 18:32:05 docker-host docker/infra/bastion:3.20.0-1/bastion01[114696]: Close session: user alpine from 192.168.1.100 port 48064 id 0
  Jul 14 18:32:05 docker-host docker/infra/bastion:3.20.0-1/bastion01[114696]: Received disconnect from 192.168.1.100 port 48064:11: disconnected by user
  Jul 14 18:32:05 docker-host docker/infra/bastion:3.20.0-1/bastion01[114696]: Disconnected from user alpine 192.168.1.100 port 48064
  (..snip..)
  ```

### Check

```bash
bastion01:~$ ps aux | grep sshd
bastion01:~$ exit
Docker-host:~$ ssh -l {{ login_user }} -p {{ public_port }} {{ docker_host_ip_address }}
{{ login_user }}@{{ docker_host_ip_address }}: Permission denied (publickey,keyboard-interactive).
```
