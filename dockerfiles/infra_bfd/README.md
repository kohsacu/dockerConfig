# BFD 実験コンテナ

## Docker Host

```bash
$ sudo mkdir -p                       ~/docker.volume/bird-{A,B}-{0,1}/{bird,local}/etc
$ sudo chown -R 1000:1000             ~/docker.volume/bird-{A,B}-{0,1}/{bird,local}/etc
$ sudo mkdir -p                       ~/docker.volume/bird-ToR-{0,1}/{bird,local}/etc
$ sudo chown -R 1000:1000             ~/docker.volume/bird-ToR-{0,1}/{bird,local}/etc
$ cp -ip ./bird.conf_bird-A-0         ~/docker.volume/bird-A-0/bird/etc/bird.conf
$ cp -ip ./bird.conf_bird-A-1         ~/docker.volume/bird-A-1/bird/etc/bird.conf
$ cp -ip ./bird.conf_bird-B-0         ~/docker.volume/bird-B-0/bird/etc/bird.conf
$ cp -ip ./bird.conf_bird-B-1         ~/docker.volume/bird-B-1/bird/etc/bird.conf
$ cp -ip ./bird.conf_bird-ToR-0       ~/docker.volume/bird-ToR-0/bird/etc/bird.conf
$ cp -ip ./bird.conf_bird-ToR-1       ~/docker.volume/bird-ToR-1/bird/etc/bird.conf
$ cp -ip ./init.scripts/80-bird.sh    ~/docker.volume/bird-A-0/local/etc/
$ cp -ip ./init.scripts/80-bird.sh    ~/docker.volume/bird-A-1/local/etc/
$ cp -ip ./init.scripts/80-bird.sh    ~/docker.volume/bird-B-0/local/etc/
$ cp -ip ./init.scripts/80-bird.sh    ~/docker.volume/bird-B-1/local/etc/
$ cp -ip ./init.scripts/80-bird.sh    ~/docker.volume/bird-ToR-0/local/etc/
$ cp -ip ./init.scripts/80-bird.sh    ~/docker.volume/bird-ToR-1/local/etc/
$ cp -ip ./init.scripts/10-network.sh ~/docker.volume/bird-A-0/local/etc/
$ cp -ip ./init.scripts/10-network.sh ~/docker.volume/bird-A-1/local/etc/
$ cp -ip ./init.scripts/10-network.sh ~/docker.volume/bird-B-0/local/etc/
$ cp -ip ./init.scripts/10-network.sh ~/docker.volume/bird-B-1/local/etc/
$ cp -ip ./init.scripts/10-network.sh ~/docker.volume/bird-ToR-0/local/etc/
$ cp -ip ./init.scripts/10-network.sh ~/docker.volume/bird-ToR-1/local/etc/
$ vim ~/docker.volume/bird-{A,B}-{0,1}/local/etc/10-network.sh
$ vim ~/docker.volume/bird-ToR-{0,1}/local/etc/10-network.sh
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
10.10.10.28               eth1       Up         04:55:23.300    3.000   15.000
10.10.10.29               eth1       Up         04:55:31.344    3.000   15.000
```

## Network

| No | Plane          | IP ADDR       | Memo |
|:---|:---------------|:--------------|:-----|
|  1 | redundant-addr | 10.10.10.0/24 | GRE Outer(type dummy) |
|  2 | router-id      | 10.10.11.0/24 | |
|  3 | bfd-redundant0 | 10.10.20.0/24 | |
|  4 | bfd-redundant1 | 10.10.21.0/24 | |
|  5 | bfd-external0  | 10.10.30.0/24 | |
|  6 | bfd-external1  | 10.10.31.0/24 | |
|  7 | bfd-internal   | 10.10.40.0/24 | GRE Inner |

### Layout diagram

```
            +--------------+               +--------------+
            | [bird-ToR-0] |               | [bird-ToR-1] |
            +-------+------+               +------+-------+
                    |(.30)                   (.30)|
         +----------+-------+             +-------+----------+          <- (AS Number:65433(my_asn1))
    [bfd-external0] |                             | [bfd-external1]
    (10.10.30.0/24) |(.10)                   (.11)| (10.10.31.0/24)
            +-------+-------+             +-------+-------+ * [bird-A-0]: 10.10.11.10/32
            |  [bird-A-0]   |             |  [bird-A-1]   | * [bird-A-1]: 10.10.11.11/32
            +---+-------+---+             +---+-------+---+ * redundant-addr(GRE Outer):10.10.10.1/32
                |(.10)  |                     |  (.11)|
                |       \__________________   ｜       |
                |           _______________|__/       |
 (10.10.20.0/24)|          |               |          | (10.10.21.0/24)
[bfd-redundant0]|          |  +---------+  |          |[bfd-redundant1]
          +-----+---+------+--+  (.40)  +--+------+---+------+          <- (AS Number:65432(my_asn0))
                    |         | [gobgp] |         |
                    |(.20)    +---------+    (.21)|
            +-------+-------+            +-------+-------+ * [bird-B-0]: 10.10.11.12/32
            |  [bird-B-0]   |            |  [bird-B-1]   | * [bird-B-1]: 10.10.11.13/32
            +-------+-------+            +-------+-------+ * redundant-addr(GRE Outer): 10.10.10.2/32
                    |(.20)                  (.21)|
          +---------+--------------+-------------+-----------+
                                   |  [bfd-internal]
                               (.1)@ (10.10.40.0/24)
```

### GRE Tunnel

- Common
```bash
$ GRE_TUN_IF_0="gre-redun0"
$ GRE_OUTER_ADDR_A_0="10.10.10.64"
$ GRE_OUTER_ADDR_B_0="10.10.10.65"
```
- bird-A-0
```bash
$ ip tunnel add "${GRE_TUN_IF_0}" mode gre remote "${GRE_OUTER_ADDR_B_0}" local "${GRE_OUTER_ADDR_A_0}"
```
- bird-B-0
```bash
$ ip tunnel add "${GRE_TUN_IF_0}" mode gre remote "${GRE_OUTER_ADDR_A_0}" local "${GRE_OUTER_ADDR_B_0}"
```
