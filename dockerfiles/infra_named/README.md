# named container

## tl;dr

- DNS サーバをコンテナで作成

```bash
$ sudo lsof -i:53
COMMAND   PID            USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
systemd-r 556 systemd-resolve   12u  IPv4  19386      0t0  UDP localhost:domain
systemd-r 556 systemd-resolve   13u  IPv4  19387      0t0  TCP localhost:domain (LISTEN)

$ systemctl status systemd-resolved.service
```
```bash
$ sudo ./volume.sh
$ ls -lR /var/opt/docker.volume/int-ns01/
$ sudo docker-compose build
```
```bash
$ sudo systemctl stop systemd-resolved.service
$ sudo systemctl disable systemd-resolved.service
$ sudo docker-compose up -d
$ sudo docker-compose ps
  Name        Command       State                   Ports
--------------------------------------------------------------------------
int-ns01   /entrypoint.sh   Up      0.0.0.0:53->53/tcp, 0.0.0.0:53->53/udp
```
```bash
$ ls -l /etc/resolv.conf
lrwxrwxrwx 1 root root 39 Sep 25 06:39 /etc/resolv.conf -> ../run/systemd/resolve/stub-resolv.conf
$ sudo rm /etc/resolv.conf
$ sudo vim /etc/resolv.conf
~
nameserver 172.31.242.152
nameserver 172.31.242.153
nameserver 172.31.241.151
search kvm0241.local kvm0242.local
~
:wq
```

