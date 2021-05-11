# named on docker

- 内向き DNS サーバをコンテナで作成

## 事前確認

`53/udp` や `53/tcp` を LISTEN しているプロセスを確認しておく。  
以下の例では `libvirt-dnsmasq`, `systemd-resolve`, `lxd` が `53/udp` と `53/tcp` を LISTEN しているので、それ以外をコンテナに割り当てる。  

```bash
$ sudo lsof -i:53
COMMAND      PID            USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
dnsmasq     1717 libvirt-dnsmasq    5u  IPv4   39801      0t0  UDP docker-host:domain 
dnsmasq     1717 libvirt-dnsmasq    6u  IPv4   39802      0t0  TCP docker-host:domain (LISTEN)
systemd-r  96912 systemd-resolve   12u  IPv4 1395638      0t0  UDP localhost:domain 
systemd-r  96912 systemd-resolve   13u  IPv4 1395639      0t0  TCP localhost:domain (LISTEN)
dnsmasq   153489             lxd    8u  IPv4 2108946      0t0  UDP docker-host:domain 
dnsmasq   153489             lxd    9u  IPv4 2108947      0t0  TCP docker-host:domain (LISTEN)
dnsmasq   153489             lxd   10u  IPv6 2108948      0t0  UDP docker-host:domain 
dnsmasq   153489             lxd   11u  IPv6 2108949      0t0  TCP docker-host:domain (LISTEN)
```
```bash
$ ss -naut | grep -E "(^Netid|:53 )"
Netid State      Recv-Q  Send-Q               Local Address:Port    Peer Address:Port    Process
udp   UNCONN     0       0                     10.129.195.1:53           0.0.0.0:*
udp   UNCONN     0       0                    127.0.0.53%lo:53           0.0.0.0:*
udp   UNCONN     0       0                    192.168.122.1:53           0.0.0.0:*
udp   UNCONN     0       0         [fd42:b783:772f:df72::1]:53              [::]:*
tcp   LISTEN     0       32                    10.129.195.1:53           0.0.0.0:*
tcp   LISTEN     0       4096                 127.0.0.53%lo:53           0.0.0.0:*
tcp   LISTEN     0       32                   192.168.122.1:53           0.0.0.0:*
tcp   LISTEN     0       32        [fd42:b783:772f:df72::1]:53              [::]:*
```

## named container

### Build & Up named Container

- `.env` file
  ```bash
  $ cp -ip ./.env{.template,}
  $ ip -4 addr show ens3
  ```
- Create docker bind mount directory
  - Master server
    ```bash
    $ sed -i 's/%%HOST_IPADDR_V4%%/172.31.242.152/' ./.env
    $ sed -i 's/int-ns00/int-ns01/' ./.env
    $ sudo ./volume.sh master
    $ ls -lR /var/opt/docker.volume/int-ns01/
    ```
  - Slave server
    ```bash
    $ sed -i 's/%%HOST_IPADDR_V4%%/172.31.241.151/' ./.env
    $ sed -i 's/int-ns00/int-ns03/' ./.env
    $ cp -ip ./files/{1.bind-master,2.bind-slave}/etc/named.conf
    $ cp -ip ./files/{1.bind-master,2.bind-slave}/etc/named.conf.local
    $ cp -ip ./files/{1.bind-master,2.bind-slave}/etc/named.conf.options
    $ sudo ./volume.sh slave
    $ ls -lR /var/opt/docker.volume/int-ns03/
    ```
- Build & Up
  ```bash
  $ sudo docker-compose build
  $ sudo docker-compose up -d
  $ sudo docker-compose ps
    Name                Command               State                          Ports
  --------------------------------------------------------------------------------------------------------
  int-ns01   /usr/sbin/named -c /etc/bi ...   Up      172.31.242.152:53->53/tcp, 172.31.242.152:53->53/udp
  ```
- Check
  ```bash
  $ sudo docker-compose exec int-named ps -aef
  UID          PID    PPID  C STIME TTY          TIME CMD
  root           1       0  0 12:08 ?        00:00:00 /sbin/docker-init -- /usr/sb
  bind           9       1  0 12:08 ?        00:00:00 /usr/sbin/named -c /etc/bind
  root          29       0  0 12:13 pts/0    00:00:00 ps -aef
  ```
  ```bash
  $ host -t any kvm0241.local 172.31.242.152
  Using domain server:
  Name: 172.31.242.152
  Address: 172.31.242.152#53
  Aliases: 
  
  kvm0241.local has SOA record int-ns1.kvm0242.local. root.kvm0241.local. 2021012301 3600 1200 1209600 900
  kvm0241.local name server int-ns3.kvm0241.local.
  kvm0241.local name server int-ns2.kvm0242.local.
  kvm0241.local name server int-ns1.kvm0242.local.
  kvm0241.local mail is handled by 10 mail.kvm0241.local.
  ```
  ```bash
  $ host -t any ipv6.l.google.com 172.31.242.152
  Using domain server:
  Name: 172.31.242.152
  Address: 172.31.242.152#53
  Aliases: 
  
  ipv6.l.google.com has IPv6 address 2404:6800:4004:80b::200e
  ```
