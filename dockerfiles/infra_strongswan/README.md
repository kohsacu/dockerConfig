# strongswan (IPsec VPN Server) on docker

## IPSec Testbed on KVM

### Network Design

```
                                      +-----------+
                                      | KVM  Host |
                                      +-----+-----+
                                            |(.254)
                                     [10.128.0.0/24]
               ----+------------------(br_unTrust0)----------------+----
                   |[vpn-01.kvm0241.global]                        |[vpn-02.kvm0242.global]
             <NAPT>|[eth0](.101)                             <NAPT>|[eth0](.102)
             +-----+-----+                                   +-----+-----+
             |  VyOS-01  |                                   |  VyOS-02  |
             +-----+-----+                                   +-----+-----+
                   |[eth1](.1)                                     |[eth1](.1)
                   |[172.31.241.0/24]                              |[172.31.242.0/24]
        +----(br_kvm0241)----+                           +----(br_kvm0242)----+
        |(.151)              |(.251)                     |(.251)              |(.152)
  +-----+------+    +--------+---------+        +--------+---------+    +-----+------+
  | ubu2004x01 |    |    docker-01     |        |    docker-02     |    | ubu2004x02 |
  +------------+    | +--------------+ |        | +--------------+ |    +------------+
                    | | strongswan01 | |        | | strongswan02 | |
                    | | (responder)  | |        | | (initiator)  | |
                    | +--------------+ |        | +--------------+ |
                    +------------------+        +------------------+
```

### VyOS

- config  
  <details><summary>example for VyOS-01.</summary><div>

  ```bash
  $ configure
  # set nat source rule 100 outbound-interface eth0
  # set nat source rule 100 source address 172.31.241.0/24
  # set nat source rule 100 translation address masquerade
  # set nat destination rule 100 inbound-interface eth0
  # set nat destination rule 100 protocol udp
  # set nat destination rule 100 destination port 500
  # set nat destination rule 100 translation port 500
  # set nat destination rule 100 translation address 172.31.241.251
  # set nat destination rule 101 inbound-interface eth0
  # set nat destination rule 101 protocol udp
  # set nat destination rule 101 destination port 4500
  # set nat destination rule 101 translation port 4500
  # set nat destination rule 101 translation address 172.31.241.251
  # set nat destination rule 102 inbound-interface eth0
  # set nat destination rule 102 protocol tcp
  # set nat destination rule 102 destination port 32768
  # set nat destination rule 102 translation port 22
  # set nat destination rule 102 translation address 172.31.241.251
  # set nat destination rule 103 inbound-interface eth0
  # set nat destination rule 103 protocol tcp
  # set nat destination rule 103 destination port 32769
  # set nat destination rule 103 translation port 22
  # set nat destination rule 103 translation address 172.31.241.151
  # set protocols static route 172.31.242.0/24 next-hop 172.31.241.251
  # commit
  # save
  Saving configuration to '/config/config.boot'...
  Done
  [edit]
  # exit
  ```
  </div></details>

### docker host

#### Config network

example for docker-01.
- resolve
  ```bash
  $ sudo vim /etc/hosts
  $ grep 10.128.0 /etc/hosts
  10.128.0.101 vpn-01.kvm0241.global
  10.128.0.102 vpn-02.kvm0242.global
  ```
- interface
  <details><summary>50-cloud-init.yaml</summary><div>

  ```yaml
  network:
    version: 2
    ethernets:
      enp1s0:
        dhcp4: false
        dhcp6: false
        accept-ra: false
        addresses:
          - 172.31.241.251/24
        gateway4: 172.31.241.1
        nameservers:
          addresses:
            - 8.8.8.8
            - 8.8.8.4
          search:
            - kvm0241.local
        routes:
            - to: 10.128.0.0/24
              via: 172.31.241.1
  ```
  </div></details>

- route
  ```bash
  $ sudo vim /etc/netplan/50-cloud-init.yaml
  $ grep -B1 -A1 10.128.0 /etc/netplan/50-cloud-init.yaml
              routes:
                  - to: 10.128.0.0/24
                    via: 172.31.241.1
  $ sudo netplan apply
  $ ip route show
  default via 172.31.241.1 dev enp1s0 proto static
  10.128.0.0/24 via 172.31.241.1 dev enp1s0 proto static
  172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown
  172.31.241.0/24 dev enp1s0 proto kernel scope link src 172.31.241.251
  ```

#### kernel parameters

- Configuration files
  ```bash
  $ ls -l ./files/sysctl.d/
  $ sudo cp -i ./files/sysctl.d/60-*.conf /etc/sysctl.d/
  ```
- Apply changes
  ```bash
  $ sudo sysctl -p /etc/sysctl.d/60-ip_forward-ipv4.conf
  $ sudo sysctl -p /etc/sysctl.d/60-ipsec-eap-ipv4.conf
  ```
- Check
  ```bash
  $ cat /proc/sys/net/ipv4/ip_forward
  1
  $ cat /proc/sys/net/ipv4/conf/default/rp_filter
  0
  $ cat /proc/sys/net/ipv4/conf/all/rp_filter
  2
  $ cat /proc/sys/net/ipv4/conf/default/accept_source_route
  0
  $ cat /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
  1
  ```

#### netfilter(Optional)

- Required Packages
  ```bash
  $ export DEBIAN_FRONTEND=noninteractive
  $ sudo -E apt install --no-install-recommends iptables-persistent
  $ ls -l /etc/iptables/
  $ sudo chmod 640 /etc/iptables/rules.v*
  $ sudo chgrp adm /etc/iptables/rules.v*
  ```
- iptables scripts
  ```bash
  $ ls -l ./files/netfilter/
  $ sudo ./files/netfilter/iptables_policies.v4 ./files/netfilter/iptables_docker-01.v4
  $ sudo ./files/netfilter/iptables_save.v4
  -rw-r----- 1 root adm 3533 Dec 28 02:47 /etc/iptables/rules.v4
  -rw-r----- 1 root adm 1243 Dec 27 23:46 /etc/iptables/rules.v4_20201227T234644
  $ diff -us /etc/iptables/rules.v4{_20201227T234644,}
  ```
  ```bash
  $ sudo ./files/netfilter/iptables_policies.v6 ./files/netfilter/iptables_docker-01.v6
  $ sudo ./files/netfilter/iptables_save.v6
  ```
  ```bash
  $ sudo systemctl restart docker.service
  ```

#### rsyslog(Optional)
- rsyslog
  ```bash
  $ cat ./files/rsyslog/20-iptables.conf | sudo tee /etc/rsyslog.d/20-iptables.conf
  :msg, contains, "[iptables: "  -/var/log/iptables.log
  & stop
  :msg, contains, "[ip6tables: " -/var/log/iptables.log
  & stop
  ```
  ```bash
  $ cat ./files/rsyslog/30-docker.conf | sudo tee /etc/rsyslog.d/30-docker.conf
  :syslogtag, startswith, "docker/local-repo/infra/strongswan:" /var/log/container-strongswan.log
  & stop
  :syslogtag, startswith, "docker/" /var/log/docker-container.log
  & stop
  ```
  ```bash
  $ sudo systemctl restart rsyslog.service
  ```
- logrotate
  ```bash
  $ sudo mkdir -p ~/Work/config/etc/logrotate.d
  $ ls -l --full-time /etc/logrotate.d/rsyslog
  -rw-r--r-- 1 root root 501 2019-03-07 21:49:31.000000000 +0900 /etc/logrotate.d/rsyslog
  $ sudo cp -ip /etc/logrotate.d/rsyslog ~/Work/config/etc/logrotate.d/
  $ sudo mv -i ~/Work/config/etc/logrotate.d/rsyslog{,_20190307T2149}
  ```
  ```bash
  $ sudo vim /etc/logrotate.d/rsyslog
  ~
  /var/log/iptables.log
  /var/log/container-strongswan.log
  /var/log/docker-container.log
  {
      rotate 100
      daily
      dateext
      olddir ./oldlogs
      missingok
      notifempty
      delaycompress
      compress
      postrotate
          /usr/lib/rsyslog/rsyslog-rotate
      endscript
  }
  ~
  :wq
  ```
  ```bash
  $ ls -ld /var/log
  drwxrwxr-x 9 root syslog 4096 Dec 28 00:00 /var/log
  $ sudo mkdir /var/log/oldlogs
  $ sudo chmod 775 /var/log/oldlogs
  $ sudo chgrp syslog /var/log/oldlogs
  $ ls -ld /var/log{,/oldlogs}
  drwxrwxr-x 10 root syslog 4096 Dec 28 02:02 /var/log
  drwxrwxr-x  2 root syslog 4096 Dec 28 02:02 /var/log/oldlogs
  ```

## strongSwan container

### Build & Up strongSwan Container

example for docker-01.
- build
  ```bash
  $ cp -ip .env{.example,}
  $ sed -i '/^CONTAINER=strongswan/s/00/01/' ./.env
  $ diff -us .env{.example,}
  (..snip..)
   STRONGSWAN_VERSION=5.8.2-1ubuntu3.1
  -CONTAINER=strongswan00
  +CONTAINER=strongswan01
   PATH_DOCKER_VOLUME=/var/opt/docker.volume
  $ sudo docker-compose build
  ```
- Create docker bind mount directory
  ```bash
  $ ./volume.sh
  ```
- start container
  ```bash
  $ sudo docker-compose up -d
  ```

### Certs files for strongSwan

[Certs files for strongswan](./strongswan.certs/README.md)

### strongSwan drop-in files

- docker-01
  ```bash
  $ cp -ip ./files/ipsec.d/ipsec_common.conf{.template,}
  $ sed -i 's/vpn-00.kvm0255/vpn-01.kvm0241/' ./files/ipsec.d/ipsec_common.conf
  $ diff -us ./files/ipsec.d/ipsec_common.conf{.template,}
  --- ./files/ipsec.d/ipsec_common.conf.template  2020-11-03 22:26:57.868982201 +0900
  +++ ./files/ipsec.d/ipsec_common.conf   2020-11-04 02:12:00.196275031 +0900
  @@ -1,7 +1,7 @@
   conn common
  -    leftcert=SrvCert_vpn-00.kvm0255.global.pem
  +    leftcert=SrvCert_vpn-01.kvm0241.global.pem
       #leftsourceip=%config
  -    leftid=vpn-00.kvm0255.global
  +    leftid=vpn-01.kvm0241.global
       leftauth=pubkey
       leftfirewall=yes
  $ sudo mv -i ./files/ipsec.d/ipsec_common.conf /var/opt/docker.volume/strongswan01/ipsec.d
  ```
  ```bash
  $ cp -ip ./files/ipsec.d/ipsec_vpn-02_to_vpn-01_EAP_Responder.conf{.template,}
  $ sudo mv -i ./files/ipsec.d/ipsec_vpn-02_to_vpn-01_EAP_Responder.conf /var/opt/docker.volume/strongswan01/ipsec.d/
  ```
  ```bash
  $ echo ": RSA $(sudo ls -1 /var/opt/docker.volume/strongswan01/ipsec.d/private/)" | \
  > sudo tee -a /var/opt/docker.volume/strongswan01/ipsec.d/ipsec_RSA.secrets
  ```
- docker-02
  ```bash
  $ cp -ip ./files/ipsec.d/ipsec_common.conf{.template,}
  $ sed -i 's/vpn-00.kvm0255/vpn-02.kvm0242/' ./files/ipsec.d/ipsec_common.conf
  $ diff -us ./files/ipsec.d/ipsec_common.conf{.template,}
  --- ./files/ipsec.d/ipsec_common.conf.template  2020-11-03 22:27:17.306813871 +0900
  +++ ./files/ipsec.d/ipsec_common.conf   2020-11-04 02:21:29.696572659 +0900
  @@ -1,7 +1,7 @@
   conn common
  -    leftcert=SrvCert_vpn-00.kvm0255.global.pem
  +    leftcert=SrvCert_vpn-02.kvm0242.global.pem
       #leftsourceip=%config
  -    leftid=vpn-00.kvm0255.global
  +    leftid=vpn-02.kvm0242.global
       leftauth=pubkey
       leftfirewall=yes
  $ sudo mv -i ./files/ipsec.d/ipsec_common.conf /var/opt/docker.volume/strongswan02/ipsec.d
  ```
  ```bash
  $ cp -ip ./files/ipsec.d/ipsec_vpn-02_to_vpn-01_EAP_Initiator.conf{.template,}
  $ sudo mv -i ./files/ipsec.d/ipsec_vpn-02_to_vpn-01_EAP_Initiator.conf /var/opt/docker.volume/strongswan02/ipsec.d/
  ```
  ```bash
  $ echo ": RSA $(sudo ls -1 /var/opt/docker.volume/strongswan02/ipsec.d/private/)" | \
  > sudo tee -a /var/opt/docker.volume/strongswan02/ipsec.d/ipsec_RSA.secrets
  ```

### Apply strongSwan config

- reload
  ```bash
  $ sudo docker-compose exec strongswan ps -aef | grep ipsec
  $ sudo docker-compose restart strongswan
  ```

### Check configration

- ipsec status
  ```bash
  $ sudo docker-compose exec strongswan ipsec statusall
  Status of IKE charon daemon (strongSwan 5.8.2, Linux 5.4.0-52-generic, x86_64):
    uptime: 79 minutes, since Nov 12 01:13:18 2020
    malloc: sbrk 2019328, mmap 0, used 1156720, free 862608
    worker threads: 11 of 16 idle, 5/0/0/0 working, job queue: 0/0/0/0, scheduled: 5
    loaded plugins: charon test-vectors ldap pkcs11 tpm aes rc2 sha2 sha1 md5 mgf1 random nonce x509 revocation constraints pubkey pkcs1 pkcs7 pkcs8 pkcs12 pgp dnskey sshkey pem gcrypt af-alg fips-prf gmp curve25519 chapoly xcbc cmac hmac ctr ccm ntru drbg curl attr kernel-netlink resolve socket-default farp stroke updown eap-identity eap-aka eap-md5 eap-gtc eap-mschapv2 eap-dynamic eap-radius eap-tls eap-ttls eap-peap eap-tnc xauth-generic xauth-eap xauth-pam tnc-tnccs dhcp lookip error-notify certexpire led addrblock unity counters
  Virtual IP pools (size/online/offline):
    100.64.0.2/32: 1/1/0
  Listening IP addresses:
    172.31.241.251
    172.17.0.1
  Connections:
        common:  %any...%any  IKEv2, dpddelay=30s
        common:   local:  [vpn-01.kvm0241.global] uses public key authentication
        common:    cert:  "C=JP, ST=Tokyo, L=Nerima, O=MyHome, OU=VPN01, CN=vpn-01.kvm0241.global"
        common:   remote: uses public key authentication
        common:   child:  dynamic === dynamic TUNNEL, dpdaction=clear
  vpn-02_to_vpn-01_EAP:  172.31.241.251...%any  IKEv2, dpddelay=30s
  vpn-02_to_vpn-01_EAP:   local:  [vpn-01.kvm0241.global] uses public key authentication
  vpn-02_to_vpn-01_EAP:    cert:  "C=JP, ST=Tokyo, L=Nerima, O=MyHome, OU=VPN01, CN=vpn-01.kvm0241.global"
  vpn-02_to_vpn-01_EAP:   remote: [vpn-02.kvm0242.global] uses EAP_MSCHAPV2 authentication with EAP identity '%any'
  vpn-02_to_vpn-01_EAP:   child:  172.31.241.0/24 === 172.31.242.0/24 TUNNEL, dpdaction=clear
  Security Associations (1 up, 0 connecting):
  vpn-02_to_vpn-01_EAP[2]: ESTABLISHED 23 minutes ago, 172.31.241.251[vpn-01.kvm0241.global]...10.128.0.102[vpn-02.kvm0242.  global]
  vpn-02_to_vpn-01_EAP[2]: Remote EAP identity: vpn-02
  vpn-02_to_vpn-01_EAP[2]: IKEv2 SPIs: babd5b672356ca3f_i 2da4c5c86cf7150c_r*, public key reauthentication in 33 minutes
  vpn-02_to_vpn-01_EAP[2]: IKE proposal: AES_CBC_128/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/CURVE_25519
  vpn-02_to_vpn-01_EAP{6}:  INSTALLED, TUNNEL, reqid 2, ESP in UDP SPIs: ca8c94c0_i cb5cf4d5_o
  vpn-02_to_vpn-01_EAP{6}:  AES_CBC_128/HMAC_SHA2_256_128, 0 bytes_i, 0 bytes_o, rekeying in 6 minutes
  vpn-02_to_vpn-01_EAP{6}:   172.31.241.0/24 === 172.31.242.0/24
  ```
- iptables
  ```bash
  $ sudo iptables -nvL FORWARD --line-number
  Chain FORWARD (policy DROP 0 packets, 0 bytes)
  num   pkts bytes target     prot opt in     out     source               destination
  1        0     0 ACCEPT     all  --  br_mgmt0 *       172.31.242.0/24      172.31.241.0/24      policy match dir in pol ipsec reqid 1 proto 50
  2        0     0 ACCEPT     all  --  *      br_mgmt0  172.31.241.0/24      172.31.242.0/24      policy match dir out pol ipsec reqid 1 proto 50
  3        0     0 DOCKER-USER  all  --  *      *       0.0.0.0/0            0.0.0.0/0
  (..snip..)
  ```
- route
  ```bash
  $ ip route show table 220
  172.31.242.0/24 via 172.31.241.1 dev br_mgmt0 proto static src 172.31.241.251 mtu 1374
  ```
