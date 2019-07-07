# install docker-ce

## tl;dr

- https://docs.docker.com/install/linux/docker-ce/ubuntu/

## インストール手順

### ログの取得

```bash
$ mkdir -p ~/Work/logs
$ LANG=C script -a ~/Work/logs/install_docker-ce_$(hostname -s)_$(date +%Y%m%dT%H%M).log
```

### インストール先ホスト

```bash
$ lsb_release -idr
Distributor ID:	Ubuntu
Description:	Ubuntu 16.04.5 LTS
Release:	16.04
```
```bash
$ uname --machine
x86_64
```

### 旧バージョンの削除確認

表示されない事。
```bash
$ dpkg -l | grep -E "(docker|docker-engine|docker.io|containerd|runc)"
<N/A>
```

### Require

以下がインストールされている事。
```bash
$ dpkg -l | grep -E "(apt-transport-https|ca-certificates|curl|gnupg-agent|software-properties-common)"
ii  apt-transport-https                         1.2.32                                       amd64        https download transport for APT
ii  ca-certificates                             20170717~16.04.2                             all          Common CA certificates
ii  curl                                        7.47.0-1ubuntu2.13                           amd64        command line tool for transferring data with URL syntax
ii  gnupg-agent                                 2.1.11-6ubuntu2.1                            amd64        GNU privacy guard - cryptographic agent
ii  software-properties-common                  0.96.20.8                                    all          manage the repositories that you install software from (common)
```

### インストール前の状態確認

```bash
$ brctl show
bridge name	bridge id		STP enabled	interfaces
br_atk-0200		8000.000000000000	no		
br_dummy-00		8000.000000000000	no		
br_ext-0120		8000.000000000000	no		
br_int-0110		8000.000000000000	no		
br_mgmt0		8000.3cd92b5ceb32	no		enp2s0

$ sudo iptables --numeric --verbose --list | grep ^Chain
Chain INPUT (policy DROP 0 packets, 0 bytes)
Chain FORWARD (policy DROP 0 packets, 0 bytes)
Chain OUTPUT (policy DROP 0 packets, 0 bytes)
Chain LOG_FORWARDINGv4 (1 references)
Chain LOG_INCOMINGv4 (1 references)
Chain LOG_OUTGOINGv4 (1 references)
Chain PING_OF_DEATH (1 references)

$ sudo ip6tables --numeric --verbose --list | grep ^Chain
Chain INPUT (policy DROP 0 packets, 0 bytes)
Chain FORWARD (policy DROP 0 packets, 0 bytes)
Chain OUTPUT (policy DROP 0 packets, 0 bytes)
Chain LOG_DROP (0 references)
Chain LOG_FLOODv6 (0 references)
Chain LOG_INCOMINGv6 (1 references)
Chain LOG_OUTGOINGv6 (1 references)

$ sudo iptables --numeric --verbose --list --table nat | grep ^Chain
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)

$ sudo ip6tables --numeric --verbose --list --table nat | grep ^Chain
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
```

### Docker Repository の公開鍵を追加

```bash
$ sudo -i sh -c 'gpg --no-default-keyring --keyring \
> /etc/apt/trusted.gpg.d/docker-ce_release_deb.gpg \
> --fingerprint'
$ sudo chmod 644 /etc/apt/trusted.gpg.d/docker-ce_release_deb.gpg
$ curl -sS 'https://download.docker.com/linux/ubuntu/gpg' | \
> sudo apt-key --keyring /etc/apt/trusted.gpg.d/docker-ce_release_deb.gpg add -
OK

$ sudo apt-key list
(..snip..)
/etc/apt/trusted.gpg.d/docker-ce_release_deb.gpg
------------------------------------------------
pub   4096R/0EBFCD88 2017-02-22
uid                  Docker Release (CE deb) <docker@docker.com>
sub   4096R/F273FCD8 2017-02-22

$ sudo apt-key fingerprint 0EBFCD88
pub   4096R/0EBFCD88 2017-02-22
      Key fingerprint = 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid                  Docker Release (CE deb) <docker@docker.com>
sub   4096R/F273FCD8 2017-02-22
```

### apt-lineの追加

```bash
$ { \
> echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"; \
> } | sudo tee /etc/apt/sources.list.d/docker-ce.list
```

### docker-ce のインストール

特に指定が無ければ最新 Ver をインストール。
```bash
$ sudo apt-get update
$ apt-cache madison docker-ce
$ apt-cache policy docker-ce
docker-ce:
  Installed: (none)
  Candidate: 5:18.09.7~3-0~ubuntu-xenial
  Version table:
     5:18.09.7~3-0~ubuntu-xenial 500
        500 https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
(..snip..)
     17.12.1~ce-0~ubuntu 500
        500 https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
(..snip..)
     17.03.0~ce-0~ubuntu-xenial 500
        500 https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages

$ dpkg -l > ~/Work/logs/dpkg-l_$(hostname -s)_$(date +%Y%m%dT%H%M).out

$ sudo apt-get install aufs-tools cgroupfs-mount
$ DOCKER_VERSION="5:18.09.7~3-0~ubuntu-xenial"
$ sudo apt-get install \
> docker-ce=${DOCKER_VERSION} \
> docker-ce-cli=${DOCKER_VERSION} \
> containerd.io

$ dpkg -l > ~/Work/logs/dpkg-l_$(hostname -s)_$(date +%Y%m%dT%H%M).out
```
```bash
$ dpkg -l | grep -E "(docker-ce|containerd.io)"
ii  containerd.io                               1.2.6-3                                      amd64        An open and reliable container runtime
ii  docker-ce                                   5:18.09.7~3-0~ubuntu-xenial                  amd64        Docker: the open-source application container engine
ii  docker-ce-cli                               5:18.09.7~3-0~ubuntu-xenial                  amd64        Docker CLI: the open-source application container engine
```

### 状態確認

#### systemctl

```bash
$ systemctl list-units docker.service
UNIT           LOAD   ACTIVE SUB     DESCRIPTION
docker.service loaded active running Docker Application Container Engine
(..snip..)

$ systemctl list-unit-files | grep docker.service
docker.service                             enabled
```

#### Bridge の状態確認

```bash
$ brctl show
bridge name	bridge id		STP enabled	interfaces
br_atk-0200		8000.000000000000	no		
br_dummy-00		8000.000000000000	no		
br_ext-0120		8000.000000000000	no		
br_int-0110		8000.000000000000	no		
br_mgmt0		8000.3cd92b5ceb32	no		enp2s0
docker0			8000.02422d0d0712	no
```

#### Netfilter の状態確認

```bash
$ sudo iptables --numeric --verbose --list | grep ^Chain
Chain INPUT (policy DROP 0 packets, 0 bytes)
Chain FORWARD (policy DROP 0 packets, 0 bytes)
Chain OUTPUT (policy DROP 0 packets, 0 bytes)
Chain DOCKER (2 references)
Chain DOCKER-ISOLATION-STAGE-1 (1 references)
Chain DOCKER-ISOLATION-STAGE-2 (2 references)
Chain DOCKER-USER (1 references)
Chain LOG_FORWARDINGv4 (1 references)
Chain LOG_INCOMINGv4 (1 references)
Chain LOG_OUTGOINGv4 (1 references)
Chain PING_OF_DEATH (1 references)


$ sudo ip6tables --numeric --verbose --list | grep ^Chain
Chain INPUT (policy DROP 0 packets, 0 bytes)
Chain FORWARD (policy DROP 0 packets, 0 bytes)
Chain OUTPUT (policy DROP 0 packets, 0 bytes)
Chain LOG_DROP (0 references)
Chain LOG_FLOODv6 (0 references)
Chain LOG_INCOMINGv6 (1 references)
Chain LOG_OUTGOINGv6 (1 references)

$ sudo iptables --numeric --verbose --list --table nat | grep ^Chain
Chain PREROUTING (policy ACCEPT 257 packets, 55614 bytes)
Chain INPUT (policy ACCEPT 117 packets, 7020 bytes)
Chain OUTPUT (policy ACCEPT 56 packets, 4716 bytes)
Chain POSTROUTING (policy ACCEPT 35 packets, 2361 bytes)
Chain DOCKER (2 references)

$ sudo ip6tables --numeric --verbose --list --table nat | grep ^Chain
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
Chain OUTPUT (policy ACCEPT 77 packets, 6789 bytes)
Chain POSTROUTING (policy ACCEPT 77 packets, 6789 bytes)
```
```bash
$ sudo iptables-save | sudo tee /etc/iptables/rules.v4_$(date +%Y%m%dT%H%M%S)_docker 1> /dev/null
$ ls -ltr /etc/iptables/ | tail
$ sudo chmod 640 /etc/iptables/rules.v4_*_docker
```

### 動作確認

```bash
$ sudo docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
```
```bash
$ sudo docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
d8aec4eeb95f: Pull complete
Digest: sha256:41a65640635299bab090f783209c1e3a3f11934cf7756b09cb2f1e02147c6ed8
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
(..snip..)
```
```bash
$ sudo docker run -it ubuntu bash
Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
(..snip..)
Status: Downloaded newer image for ubuntu:latest
root@c0f8544cfd62:/#
root@c0f8544cfd62:/# exit
```
```bash
$ sudo docker container ls -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                        PORTS               NAMES
c0f8544cfd62        ubuntu              "bash"              7 minutes ago       Exited (127) 30 seconds ago                       lucid_liskov
c027335458e5        hello-world         "/hello"            9 minutes ago       Exited (0) 9 minutes ago                          zen_lalande

$ sudo docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ubuntu              latest              cf5ff47c2b80        2 weeks ago         64.8MB
hello-world         latest              df8c1d4877c5        6 months ago        665kB
```

### ログ取得の終了

```bash
$ exit
$ ls -l ~/Work/logs/install_docker-ce_$(hostname -s)_*.log
```

## 設定変更手順

以下、任意で実施すること。

- データ領域の PATH を変更
- Docker デフォルト bridge ネットワーク名を変更

### ログの取得

```bash
$ mkdir -p ~/Work/logs
$ LANG=C script -a ~/Work/logs/conf_docker-ce_$(hostname -s)_$(date +%Y%m%dT%H%M).log
```

### 設定変更

#### サービスの停止

```bash
$ sudo systemctl stop docker.service
```

#### データ領域の移動

```bash
$ sudo mv -i /var/lib/docker /home/docker-storage
```

#### docker0 bridge の削除

```bash
$ sudo ip link set docker0 down
$ sudo brctl delbr docker0
```

#### 変更後 bridge の作成

```bash
$ grep ^source /etc/network/interfaces
source /etc/network/interfaces.d/*
```
```bash
$ sudo vim /etc/network/interfaces.d/60-docker
~
# Docker Default Bridge(NAPT)
auto br_docker0
iface br_docker0 inet static
        address 172.17.255.254
        netmask 255.255.0.0
        bridge_ports none
        bridge_stp off
        bridge_fd 0
        bridge_maxwait 5
iface br_docker0 inet6 manual
~
:wq
```
```bash
$ sudo systemctl restart networking.service
```
```bash
$ ip -4 addr show br_docker0
13: br_docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 172.17.255.254/16 brd 172.17.255.255 scope global br_docker0
       valid_lft forever preferred_lft forever
```

#### 設定ファイルの編集

```bash
$ sudo vim /etc/docker/daemon.json
~
{
    "data-root": "/home/docker-storage",
    "storage-driver": "overlay2",
    "bridge": "br_docker0"
}
~
:wq
```

#### サービスの起動

```bash
$ sudo systemctl daemon-reload
$ sudo systemctl start docker.service
```

#### 設定確認

```bash
$ sudo docker image inspect hello-world | jq .[].GraphDriver
{
  "Data": {
    "MergedDir": "/home/docker-storage/overlay2/5e11eeb3ab088480ff9237477c2a7460b9bcff38e536580fbabdaf4622762b7b/merged",
    "UpperDir": "/home/docker-storage/overlay2/5e11eeb3ab088480ff9237477c2a7460b9bcff38e536580fbabdaf4622762b7b/diff",
    "WorkDir": "/home/docker-storage/overlay2/5e11eeb3ab088480ff9237477c2a7460b9bcff38e536580fbabdaf4622762b7b/work"
  },
  "Name": "overlay2"
}
```
```bash
$ sudo docker network inspect bridge | jq .[].IPAM
{
  "Driver": "default",
  "Options": null,
  "Config": [
    {
      "Subnet": "172.17.0.0/16",
      "Gateway": "172.17.255.254"
    }
  ]
}
```

### ログ取得の終了

```bash
$ exit
$ ls -l ~/Work/logs/conf_docker-ce_$(hostname -s)_*.log
```
