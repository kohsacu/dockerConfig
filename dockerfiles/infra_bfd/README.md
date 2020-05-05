# BFD 実験コンテナ

- iBGP
  - ECMP
- eBGP
- vrrp(keepalived)

## Docker Host

```bash
$ sudo cp -ipR ./docker.volume /var/opt/
$ sudo chown root.  /var/opt/docker.volume

$ for i in $(ls -1d /var/opt/docker.volume/bird-{A,B,ToR}-{0,1}/local/etc); do cp -ip ./init.scripts/80-bird.sh ${i}/; done
$ for i in $(ls -1d /var/opt/docker.volume/bird-{B,ToR}-{0,1}/local/etc); do cp -ip ./init.scripts/30-keeplalived.sh ${i}/; done
$ for i in $(ls -1d /var/opt/docker.volume/bird-{server01,client01,client02}/local/etc); do cp -ip ./init.scripts/90-http.server.sh ${i}/; done
```
```bash
$ cp -ip ./init.scripts/80-gobgpd.sh  /var/opt/docker.volume/bird-gobgp/local/etc/
```
```bash
$ sudo docker-compose build
$ sudo docker-compose up -d
  or
$ sudo docker-compose up -d bird-gobgp

$ sudo docker-compose up -d bird-client01
$ sudo docker-compose up -d bird-client02

$ sudo docker-compose up -d bird-server01
$ sudo docker-compose exec bird-server01 ip r s
default via 172.18.0.1 dev eth0 
100.64.0.0/24 dev eth1 proto kernel scope link src 100.64.0.126 
172.18.0.0/16 dev eth0 proto kernel scope link src 172.18.0.3

$ sudo docker-compose up -d bird-A-0
$ sudo docker-compose exec bird-A-0 birdc show protocols iBGP_gobgp_0
BIRD v2.0.5 ready.
Name       Proto      Table      State  Since         Info
iBGP_gobgp_0 BGP        ---        up     16:49:19.428  Established

$ sudo docker-compose up -d bird-B-0
$ sudo docker-compose up -d bird-ToR-0

$ sudo docker-compose exec bird-gobgp gobgp global rib
$ DEST_HOST=100.64.0.126; sudo -E docker-compose exec bird-client01 curl --noproxy ${DEST_HOST} http://${DEST_HOST}:8000/hostname
bird-server01

$ sudo docker-compose up -d bird-A-1
$ sudo docker-compose up -d bird-B-1
$ sudo docker-compose up -d bird-ToR-1

$ sudo docker-compose ps
    Name        Command   State   Ports
---------------------------------------
bird-A-0        init.sh   Up           
bird-A-1        init.sh   Up           
bird-B-0        init.sh   Up           
bird-B-1        init.sh   Up           
bird-ToR-0      init.sh   Up           
bird-ToR-1      init.sh   Up           
bird-client01   init.sh   Up           
bird-client02   init.sh   Up           
bird-gobgp      init.sh   Up           
bird-server01   init.sh   Up           
```

## command-line example

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
10.10.20.20               eth1       Up         16:13:12.007    3.000   15.000
10.10.21.21               eth2       Up         16:49:34.253    3.000   15.000

$ sudo docker-compose exec bird-A-0 birdc show route 10.100.1.0/24 all
BIRD v2.0.5 ready.
Table master4:
10.100.1.0/24        unicast [iBGP_B_0 17:00:16.983] * (100) [i]
        via 10.10.20.20 on eth1
        Type: BGP univ
        BGP.origin: IGP
        BGP.as_path: 
        BGP.next_hop: 10.10.20.20
        BGP.local_pref: 200
                     unicast [iBGP_B_1 20:29:07.852] (100) [i]
        via 10.10.21.21 on eth2
        Type: BGP univ
        BGP.origin: IGP
        BGP.as_path: 
        BGP.next_hop: 10.10.21.21
        BGP.local_pref: 200

$ sudo docker-compose exec bird-A-0 birdc show route 100.64.0.0/24 all
BIRD v2.0.5 ready.
Table master4:
100.64.0.0/24        unicast [eBGP_ToR_0 19:02:47.764] * (100) [AS65433i]
        via 10.10.30.30 on eth0
        Type: BGP univ
        BGP.origin: IGP
        BGP.as_path: 65433
        BGP.next_hop: 10.10.30.30
        BGP.local_pref: 100
                     unicast [eBGP_ToR_1 19:08:08.432] (100-) [AS65433i]
        via 10.10.30.31 on eth0
        Type: BGP univ
        BGP.origin: IGP
        BGP.as_path: 65433
        BGP.next_hop: 10.10.30.31
        BGP.local_pref: 100
```
- FIB (Forwarding Information Base)
```bash
$ sudo docker-compose exec bird-A-0 ip route show 10.100.1.0/24
10.100.1.0/24 proto bird metric 32 
        nexthop via 10.10.20.20 dev eth1 weight 1 
        nexthop via 10.10.21.21 dev eth2 weight 1
$ sudo docker-compose exec bird-A-0 ip route show 100.64.0.0/24 
100.64.0.0/24 via 10.10.30.30 dev eth0 proto bird metric 32
```

## Network

| No | Plane          | Network Addr  | Memo |
|:---|:---------------|--------------:|:-----|
|  1 | redundant-addr | 10.10.10.0/24 | `type dummy` |
|  2 | router-id      | 10.10.11.0/24 | |
|  3 | bfd-redundant0 | 10.10.20.0/24 | |
|  4 | bfd-redundant1 | 10.10.21.0/24 | |
|  5 | bfd-external0  | 10.10.30.0/24 | |
|  6 | vrrp-closed01  | 10.100.1.0/24 | |
|  7 | vrrp-transfer  | 100.64.0.0/24 | |
|  8 | handoverA      | 192.0.2.0/29  | `disable` |
|  9 | handoverB      | 192.0.2.8/29  | |
| 10 | handoverC      | 192.0.2.16/29 | |

### Layout diagram

```
                                 +---------------+
                                 | bird-server01 |
                                 +-------+-------+                   * [vrrp-transfer]
                                         |(.126)                       (100.64.0.0/24)
                +--------+---------------+---------------+--------+
                         |            (vip.4)            |
                         |(.5)                           |(.6)
                 +-------+------+(.21)       (.22)+------+-------+
                 | [bird-ToR-0] +-----------------+ [bird-ToR-1] |   * [hadoverC(my_asn4)]
                 +-------+------+   [handoverC]   +------+-------+     (192.0.2.16/29)
                         |(.30)                          |(.31)
                +--------+-------------------------------+--------+  <- [AS Number:65433](my_asn1)
                         |                               |
                         |(.10)                          |(.11)      * [bfd-external0]
                 +-------+------+(.5)         (.6)+------+-------+     (10.10.30.0/24)
                 |  [bird-A-0]  +------- X -------+  [bird-A-1]  |
                 +---+-------+--+   [handoverA]   +--+-------+---+   * [handoverA(my_asn2)]
                     |(.10)  |(.10)                  |(.11)  |(.11)    (192.0.2.0/29)
                     |       \____________________   |       |
  * [bfd-redundant0] |           _________________|__/       |       * [bfd-redundant1]
    (10.10.20.0/24)  |          |   +---------+   |          |         (10.10.21.0/24)
                     |          |   |  (.90)  |   |          |
                +----+---+------+---+ [bird-  +---+------+---+----+  <- [AS Number:65432](my_asn0)
                         |          |  gobgp] |          |
                         |(.20)     +---------+          |(.21)
                 +-------+------+(.13)       (.14)+------+-------+
                 |  [bird-B-0]  +-----------------+  [bird-B-1]  |
                 +-------+------+   [handoverB]   +------+-------+   * [handoverB(my_asn3)]
                         |(.252)                         |(.253)       (192.0.2.8/29)
                         |           (vip.254)           |
                +--------+----+---------------------+----+--------+
                              |(.131)               |(.132)          * [vrrp-closed01]
                      +-------+-------+     +-------+-------+          (10.100.1.0/24)
                      | bird-client01 |     | bird-client02 |
                      +---------------+     +---------------+
```

### GRE Tunnel

- Common
```bash
$ GRE_TUN_IF_0="gre-redun0"
$ GRE_OUTER_ADDR_A_0="10.10.10.1"
$ GRE_OUTER_ADDR_B_0="10.10.10.129"
```
- bird-A-0
```bash
$ ip tunnel add "${GRE_TUN_IF_0}" mode gre remote "${GRE_OUTER_ADDR_B_0}" local "${GRE_OUTER_ADDR_A_0}"
```
- bird-B-0
```bash
$ ip tunnel add "${GRE_TUN_IF_0}" mode gre remote "${GRE_OUTER_ADDR_A_0}" local "${GRE_OUTER_ADDR_B_0}"
```
