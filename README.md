# Docker configuration files space.

## ポリシー

* いわゆる `docker0` ブリッジはコンテナ内の apt や git clone でのみ使用する
* コンテナ間や対向装置との通信は、別途 `docker network connect` で接続するブリッジを使用する
* ssh サーバはインストールせず `exec -it sh` にてコンテナ内の作業を実施する

# コンテナ作成手順

## 作業ログの取得

```
$ mkdir -p ~/Work/logs
$ script -a ~/Work/logs/conf_docker-ce_$(hostname -s)_$(date +%Y%m%dT%H%M).log
```

## Docker ホスト側作業

### 対象ホスト情報

Version 情報を確認する。
```
$ lsb_release -idr
Distributor ID:	Ubuntu
Description:	Ubuntu 16.04.5 LTS
Release:	16.04
```
```
$ sudo docker version
Client:
 Version:           18.09.0
(..snip..)
Server: Docker Engine - Community
 Engine:
  Version:          18.09.0
(..snip..)
```

### Data Volume の準備

ホスト側のディレクトリを作成する。
```
$ sudo mkdir -p /export/home1/docker.volume \
> && sudo chown 1000:1000 $_
```

### Dockerfile の作成

#### 作業用ディレクトリの作成

この PATH にて `docker build` を実行する。
```
$ mkdir -p ~/git-local/github.dockerConfig/dockerfiles && cd $_
```
コンテナ(イメージ)と依存性が少ない設定ファイル等を配置し ADD や COPY でコンテナ内に配置する。
```
$ mkdir -p ./common
$ vim ./common/static-routes.sh
~
#!/bin/bash

#/sbin/ip route add 10.32.201.0/24  via NEXT-HOP dev eth1
#/sbin/ip route add 172.31.11.0/24  via NEXT-HOP dev eth1
#/sbin/ip route add 172.31.252.0/24 via NEXT-HOP dev eth1
#/sbin/ip route add 10.255.3.0/24   via NEXT-HOP dev eth1
~
:wq
$ sudo chmod a+x $_
```
```
$ vim ./common/init.sh
~
#!/bin/bash

DROPIN_DIR="/home/devel/volume/init.d"

# Container starting massages...
echo "Starting container init scripts on $(cat /etc/hostname) ..."

for f in ${DROPIN_DIR}/*; do
    case "${f}" in
        *.sh) echo "$0: running $f"; . "$f" ;;
        *)    echo "$0: ignoring $f" ;;
    esac
echo
done

exec /bin/bash
~
:wq
$ sudo chmod a+x $_
```
コンテナ(イメージ)特有な設定ファイルやコンテナ内で展開する Tarball 等を配置し、必要に応じて ADD や COPY でコンテナ内に配置する。
```
$ mkdir -p ./require
```

#### Dockerfile の作成

コンテナ(イメージ)別にディレクトリを作成する。
```
$ mkdir -p ./base_ubuntu18.04 && cd $_
```
Dockerfile を作成(＝ git clone)する。
```
$ vim ./Dockerfile
:set paste
~
FROM ubuntu:18.04

(..snip..)

ENTRYPOINT ["init.sh"]

VOLUME ["/home/devel/volume"]
USER devel
WORKDIR ${HOME}
~
:wq
```

#### docker build

```
$ sudo docker image ls -a
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
(..snip..)
ubuntu              18.04               1d9c17228a9e        3 weeks ago         86.7MB

$ cd ../
$ REPOSITORY='base/ubuntu1804'; TAG='0.3'
$ time sudo docker build --tag ${REPOSITORY}:${TAG} --file ./base_ubuntu18.04/Dockerfile .

$ sudo docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
base/ubuntu1804     0.3                 7d1d490cafc1        6 minutes ago       253MB
base/ubuntu1804     0.2                 18b9c7d562bf        8 days ago          253MB
base/ubuntu1804     0.1                 d4f8ded9f23b        2 weeks ago         252MB
ubuntu              18.04               1d9c17228a9e        5 weeks ago         86.7MB
```

#### docker create

コンテナ起動時に実行したいスクリプトを volume 配下に配置する。
```
$ CONTAINER="victim03"
$ sudo mkdir -p /export/home1/docker.volume/${CONTAINER}/init.d
$ sudo cp -ip ./common/static-routes.sh $_
$ sudo chown -R 1000:1000 /export/home1/docker.volume/${CONTAINER}
$ ls -lR $_
```
```
$ CONTAINER="attacker03"
$ sudo mkdir -p /export/home1/docker.volume/${CONTAINER}/init.d
$ sudo cp -ip ./common/static-routes.sh $_
$ sudo chown -R 1000:1000 /export/home1/docker.volume/${CONTAINER}
$ ls -lR $_
```
run ではなく create と start を別々に実施する。
```
$ CONTAINER="victim03"
$ sudo docker create \
> --name ${CONTAINER} --hostname ${CONTAINER} \
> --interactive --user=0:0 \
> --volume /export/home1/docker.volume/${CONTAINER}:/home/devel/volume \
> --cap-add=NET_ADMIN \
> ${REPOSITORY}:${TAG}
```
```
$ CONTAINER="attacker03"
...
```
```
$ sudo docker container ls -a
CONTAINER ID        IMAGE                 COMMAND             CREATED             STATUS                    PORTS               NAMES
6685c9e2d343        base/ubuntu1804:0.3   "init.sh"           4 seconds ago       Created                                       attacker03
2fc463431bec        base/ubuntu1804:0.3   "init.sh"           57 seconds ago      Created                                       victim03
9295030ec4af        base/ubuntu1804:0.2   "init.sh"           8 days ago          Exited (137) 7 days ago                       attacker02
45c5691c8e8b        base/ubuntu1804:0.2   "init.sh"           8 days ago          Exited (137) 7 days ago                       victim02
(..snip..)
```

### Network の作成

#### Network の作成

Network は作成済とする。

#### Container と Network の接続

Network 名を確認する。
```
$ sudo docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
b854949eb1cb        br_atk0201          bridge              local
383e92915dcf        br_ctl0252          bridge              local
a6305b2917ab        br_int0011          bridge              local
6c8ab85fd788        bridge              bridge              local
(..snip..)
```

br_int0011 との接続例。
```
$ CONTAINER="victim03"
$ sudo docker network connect --ip 172.31.11.13 br_int0011 ${CONTAINER}
```
br_atk0201 との接続例。
```
$ CONTAINER="attacker03"
$ sudo docker network connect --ip 10.32.201.13 br_atk0201 ${CONTAINER}
```

### Container の起動

#### コンテナ個別設定

スクリプトを修正する。
```
DOCKER-HOST:~$ CONTAINER="victim03"
DOCKER-HOST:~$ sudo perl -pi -e 's/NEXT-HOP/172.31.11.254/' /export/home1/docker.volume/${CONTAINER}/init.d/static-routes.sh
DOCKER-HOST:~$ vim $_
(..or..)
DOCKER-HOST:~$ CONTAINER="attacker03"
DOCKER-HOST:~$ sudo perl -pi -e 's/NEXT-HOP/10.32.201.254/' /export/home1/docker.volume/${CONTAINER}/init.d/static-routes.sh
DOCKER-HOST:~$ vim $_
```

#### docker start

起動と接続確認例 その1
```
$ CONTAINER="victim03"
$ sudo docker container start ${CONTAINER}
$ sudo docker container exec -it ${CONTAINER} ip addr show
(..snip..)
120: eth0@if121: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
124: eth1@if125: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:1f:0b:0a brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.31.11.11/24 brd 172.31.11.255 scope global eth1
       valid_lft forever preferred_lft forever

$ sudo docker container exec -it ${CONTAINER} ip route show | grep -v link
default via 172.17.0.1 dev eth0
10.32.201.0/24 via 172.31.11.254 dev eth1
10.255.3.0/24 via 172.31.11.254 dev eth1
172.31.252.0/24 via 172.31.11.254 dev eth1

$ sudo docker container exec -it ${CONTAINER} ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.1  0.0  18376  2864 ?        Ss   17:14   0:00 /bin/bash
root        20  0.0  0.0  34400  2812 pts/0    Rs+  17:14   0:00 ps aux
```
起動と接続確認例 その2
```
$ CONTAINER="attacker03"
$ sudo docker container start ${CONTAINER}
$ sudo docker container exec -it ${CONTAINER} ip addr show
(..snip..)
122: eth0@if123: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:11:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
126: eth1@if127: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:0a:20:c9:0a brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.32.201.11/24 brd 10.32.201.255 scope global eth1
       valid_lft forever preferred_lft forever

$ sudo docker container exec -it ${CONTAINER} ip route show | grep -v link
default via 172.17.0.1 dev eth0
10.255.3.0/24 via 10.32.201.254 dev eth1
172.31.11.0/24 via 10.32.201.254 dev eth1
172.31.252.0/24 via 10.32.201.254 dev eth1

$ sudo docker container exec -it ${CONTAINER} ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0  18376  2828 ?        Ss   17:31   0:00 /bin/bash
root        30  0.0  0.0  34400  2756 pts/0    Rs+  17:34   0:00 ps aux
```

#### 設定確認

```
$ sudo docker container exec -it ${CONTAINER} grep -v -e '^\s*#' -e '^\s*$' /etc/apt/sources.list
deb http://jp.archive.ubuntu.com/ubuntu/ bionic main restricted
deb http://jp.archive.ubuntu.com/ubuntu/ bionic-updates main restricted
deb http://jp.archive.ubuntu.com/ubuntu/ bionic universe
deb http://jp.archive.ubuntu.com/ubuntu/ bionic-updates universe
deb http://jp.archive.ubuntu.com/ubuntu/ bionic multiverse
deb http://jp.archive.ubuntu.com/ubuntu/ bionic-updates multiverse
deb http://jp.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ bionic-security main restricted
deb http://security.ubuntu.com/ubuntu/ bionic-security universe
deb http://security.ubuntu.com/ubuntu/ bionic-security multiverse
```
```
$ LANG=en_US ls -aln /export/home1/docker.volume/${CONTAINER}/
total 12
drwxr-xr-x 3 1000 1000 4096 Jan 30 02:18 .
drwxr-xr-x 6 1000 1000 4096 Jan 30 02:09 ..
drwxr-xr-x 2 1000 1000 4096 Jan 30 02:13 init.d

$ sudo docker container exec -it --user=1000:1000 ${CONTAINER} touch /home/devel/volume/user
$ sudo docker container exec -it                  ${CONTAINER} touch /home/devel/volume/root

$ sudo docker container exec -it ${CONTAINER} ls -aln /home/devel/volume
total 12
drwxr-xr-x 3 1000 1000 4096 Jan 29 17:19 .
drwxr-xr-x 7 1000 1000 4096 Jan 29 16:57 ..
drwxr-xr-x 2 1000 1000 4096 Jan 29 17:13 init.d
-rw-r--r-- 1    0    0    0 Jan 29 17:19 root
-rw-r--r-- 1 1000 1000    0 Jan 29 17:19 user

$ LANG=en_US ls -aln /export/home1/docker.volume/${CONTAINER}/
total 12
drwxr-xr-x 3 1000 1000 4096 Jan 30 02:19 .
drwxr-xr-x 6 1000 1000 4096 Jan 30 02:09 ..
drwxr-xr-x 2 1000 1000 4096 Jan 30 02:13 init.d
-rw-r--r-- 1    0    0    0 Jan 30 02:19 root
-rw-r--r-- 1 1000 1000    0 Jan 30 02:19 user
```
```
DOCKER-HOST:~$ sudo docker container exec -it ${CONTAINER} ping -c 2 172.31.11.13
```

### 通常ログイン

```
DOCKER-HOST:~$ CONTAINER="attacker03"
(..or..)
DOCKER-HOST:~$ CONTAINER="victim03"

DOCKER-HOST:~$ sudo docker container exec -it --user=1000:1000 ${CONTAINER} bash
devel@victim03:~$ id
uid=1000(devel) gid=1000(devel) groups=1000(devel)

devel@victim03:~$ ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0  18376  2864 ?        Ss   17:14   0:00 /bin/bash
devel       89  0.2  0.0  19412  4104 pts/0    Ss   17:25   0:00 bash
devel      104  0.0  0.0  34400  2676 pts/0    R+   17:25   0:00 ps aux

devel@victim03:~$ exit
```

### 作業ログ取得の終了

```
$ exit
$ date; ls -l ~/Work/logs/conf_docker-ce_$(hostname -s)_*.log
```
