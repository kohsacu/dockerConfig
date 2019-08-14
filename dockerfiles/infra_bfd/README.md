# BFD 実験コンテナ

## Docker Host

```bash
$ sudo mkdir -p                       ~/docker.volume/bird-{A,B}-{0,1}/{bird,local}/etc
$ sudo chown -R 1000:1000             ~/docker.volume/bird-{A,B}-{0,1}/{bird,local}/etc
$ cp -ip ./bird.conf_bird-A-0         ~/docker.volume/bird-A-0/bird/etc/bird.conf
$ cp -ip ./bird.conf_bird-A-1         ~/docker.volume/bird-A-1/bird/etc/bird.conf
$ cp -ip ./bird.conf_bird-B-0         ~/docker.volume/bird-B-0/bird/etc/bird.conf
$ cp -ip ./bird.conf_bird-B-1         ~/docker.volume/bird-B-1/bird/etc/bird.conf
$ cp -ip ./init.scripts/80-bird.sh    ~/docker.volume/bird-A-0/local/etc/
$ cp -ip ./init.scripts/80-bird.sh    ~/docker.volume/bird-A-1/local/etc/
$ cp -ip ./init.scripts/80-bird.sh    ~/docker.volume/bird-B-0/local/etc/
$ cp -ip ./init.scripts/80-bird.sh    ~/docker.volume/bird-B-1/local/etc/
$ cp -ip ./init.scripts/10-network.sh ~/docker.volume/bird-A-0/local/etc/
$ cp -ip ./init.scripts/10-network.sh ~/docker.volume/bird-A-1/local/etc/
$ cp -ip ./init.scripts/10-network.sh ~/docker.volume/bird-B-0/local/etc/
$ cp -ip ./init.scripts/10-network.sh ~/docker.volume/bird-B-1/local/etc/
$ vim ~/docker.volume/bird-{A,B}-{0,1}/local/etc/10-network.sh
```
```bash
$ sudo mkdir -p                       ~/docker.volume/bird-gobgp/{go,local}/etc
$ sudo chown -R 1000:1000             ~/docker.volume/bird-gobgp/{go,local}/etc
$ cp -ip ./gobgpd.conf                ~/docker.volume/bird-gobgp/go/etc/
$ cp -ip ./init.scripts/80-gobgpd.sh  ~/docker.volume/bird-gobgp/local/etc/
```
```bash
$ sudo docker-compose build
$ sudo docker-compose up -d
```

## command-line client

- rich client
```bash
$ sudo docker container exec -it bird-A-0 birdc
BIRD v2.0.5 ready.
bird> exit
```
- Lightweight client
```bash
$ sudo docker container exec -it bird-A-0 birdcl show bfd sessions bfd_redun0
BIRD v2.0.5 ready.
bfd_redun0:
IP address                Interface  State      Since         Interval  Timeout
203.0.113.28              eth1       Up         04:55:23.300    3.000   15.000
203.0.113.29              eth1       Up         04:55:31.344    3.000   15.000
```

## Network

### Layout diagram

```
                   +-------+
                   | [ToR] |
                   +---+---+
                       |(.33)                     [bfd-external]
  ----------+----------+----------+-------------------------------
            |                     |            (203.0.113.32/28)
            |(.34)                |(.35)
    +-------+-------+     +-------+-------+    * [bird-A-0]: 203.0.113.10/32
    |  [bird-A-0]   |     |  [bird-A-1]   |    * [bird-A-1]: 203.0.113.11/32
    +-------+-------+     +-------+-------+    * REDUNDANT_ADDR(GRE Outer): 203.0.113.64/32
            |(.18)                |(.19)                          (.25)
            |                     |              [bfd-redundant]  +--------------+
  ----------+---------------------+-------------------------------+ [bird-gobgp] |
            |                     |            (203.0.113.16/28)  +--------------+
            |(.28)                |(.29)
    +-------+-------+     +-------+-------+    * [bird-B-0]: 203.0.113.12/32
    |  [bird-B-0]   |     |  [bird-B-1]   |    * [bird-B-1]: 203.0.113.13/32
    +-------+-------+     +-------+-------+    * REDUNDANT_ADDR(GRE Outer): 203.0.113.65/32
            |(.50)                |(.51)
            |                     |               [bfd-internal]
  ----------+----------+----------+-------------------------------
                       |                       (203.0.113.48/28)
                       @
```

### GRE Tunnel

- Common
```bash
$ GRE_TUN_IF_0="gre-redun0"
$ GRE_OUTER_ADDR_A_0="203.0.113.64"
$ GRE_OUTER_ADDR_B_0="203.0.113.65"
```
- bird-A-0
```bash
$ ip tunnel add "${GRE_TUN_IF_0}" mode gre remote "${GRE_OUTER_ADDR_B_0}" local "${GRE_OUTER_ADDR_A_0}"
```
- bird-B-0
```bash
$ ip tunnel add "${GRE_TUN_IF_0}" mode gre remote "${GRE_OUTER_ADDR_A_0}" local "${GRE_OUTER_ADDR_B_0}"
```

