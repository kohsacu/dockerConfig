# Certs files for strongswan

## Preparations
- New shell inside the container
  ```bash
  $ sudo docker-compose exec strongswan bash
  ```
- Create working directory
  ```bash
  root@strongswan01:# cd /var/opt/strongswan.certs
  root@strongswan01:# mkdir -p ./{cacerts,certs,clients,private}
  root@strongswan01:# chmod 700 ./private
  root@strongswan01:# chown root. ./mk*.sh
  root@strongswan01:# chmod 744   ./mk*.sh
  ```

## Local CA
オレオレ証明局の秘密鍵と証明書。
- Only the first one
  ```bash
  root@strongswan01:# ./mk01CA.sh 0 mk00Certificate_MyCA.strongSwan.local
  ```
- Second time or after
  ```bash
  root@strongswan01:# ./mk01CA.sh 1 mk00Certificate_MyCA.strongSwan.local
  CA_KEY : ./private/MyCaKey_strongSwan.local.pem
  CA_CERT: ./cacerts/MyCaCert_strongSwan.local.pem
  root@strongswan01:# ls -l ./private/MyCaKey_strongSwan.local.pem ./cacerts/MyCaCert_strongSwan.local.pem
  -rw-r--r-- 1 root root 2021 Oct  3 15:16 ./cacerts/MyCaCert_strongSwan.local.pem
  -rw------- 1 root root 3247 Oct  3 15:16 ./private/MyCaKey_strongSwan.local.pem
  ```
- Validity check
  ```bash
  root@strongswan01:# openssl x509 -noout -text   -in ./cacerts/MyCaCert_strongSwan.local.pem
  root@strongswan01:# openssl x509 -noout -dates  -in ./cacerts/MyCaCert_strongSwan.local.pem
  notBefore=Oct  3 06:16:05 2020 GMT
  notAfter=Oct  4 06:16:05 2030 GMT
  ```

## Server Certification
サーバ秘密鍵とオレオレ証明局が発行したサーバ証明書。
- Validity SERVER_CERT
  ```bash
  root@strongswan01:# ./mk02ServerKey.sh 0 mk00Certificate_vpn-01.kvm0241.global
  ```
- Check SERVER_CERT
  ```bash
  root@strongswan01:# ./mk02ServerKey.sh 1 mk00Certificate_vpn-01.kvm0241.global
  CA_KEY : ./private/MyCaKey_strongSwan.local.pem
  CA_CERT: ./cacerts/MyCaCert_strongSwan.local.pem
  SERVER_KEY:  ./private/SrvKey_vpn-01.kvm0241.global.pem
  SERVER_CERT: ./certs/SrvCert_vpn-01.kvm0241.global.pem
  GFQDN: vpn-01.kvm0241.global
  root@strongswan01:# openssl rsa -text -noout               -in ./private/SrvKey_vpn-01.kvm0241.global.pem
  root@strongswan01:# openssl x509 -noout -text -fingerprint -in ./certs/SrvCert_vpn-01.kvm0241.global.pem
  root@strongswan01:# openssl x509 -noout -dates             -in ./certs/SrvCert_vpn-01.kvm0241.global.pem
  notBefore=Oct  3 06:35:19 2020 GMT
  notAfter=Oct  3 06:35:19 2023 GMT
  root@strongswan01:# LC_ALL=C date --universal
  Sat Oct  3 06:36:29 UTC 2020
  ```

## Client Certification for Road Warrior (Optional)
- Validity CLIENT_CERT (PKCS #12)  
  for L2TP/IPSec RSA
  ```bash
  root@strongswan01:# ./mk03ClinetsKey.sh 1 mk00Certificate_android-01_to_vpn-01_RSA
  CA_KEY : ./private/MyCaKey_strongSwan.local.pem
  CA_CERT: ./cacerts/MyCaCert_strongSwan.local.pem
  CLIENT_KEY : android-01.l2tp.local_ClientKey.pem
  CLIENT_CERT: android-01.l2tp.local_ClientCert.pem
  CLIENT_LOCALITY_NAME: Nerima
  CLIENT_ORG_UNIT_NAME: android-01.VPN01
  CLIENT_CN: android-01@l2tp.local
  ```
- Update CLIENT_CERT (PKCS #12)  
  for L2TP/IPSec RSA
  ```bash
  root@strongswan01:# ./mk03ClinetsKey.sh 0 mk00Certificate_android-01_to_vpn-01_RSA
  (..snip..)
  $ openssl genrsa -out ./clients/android-01.l2tp.local_ClientKey.pem 4096
  (..snip..)
  $ ipsec pki --pub --in ./clients/android-01.l2tp.local_ClientKey.pem --type rsa ...
  $ openssl pkcs12 -export -inkey ./clients/android-01.l2tp.local_ClientKey.pem ...
  Enter Export Password: <vpn!RoadWarrior> # <= 端末に読み込ませる時に入力するパスワード
  Verifying - Enter Export Password: 
  ```
- Check CLIENT_CERT (PKCS #12)  
  for L2TP/IPSec RSA
  ```bash
  root@strongswan01:# openssl x509 -text -noout  -in ./clients/android-01.l2tp.local_ClientCert.pem | grep Subject:
  root@strongswan01:# openssl x509 -noout -dates -in ./clients/android-01.l2tp.local_ClientCert.pem
  root@strongswan01:# LC_ALL=C date --universal
  root@strongswan01:# tar -C clients -cpf ./p12.ClientCert_android-01.l2tp_to_MyHome_RSA.tar android-01.l2tp.local_ClientCert.p12
  ```

## Client Certificate Revocation for Road Warrior (Optional)
- Usage
  ```bash
  root@strongswan01:# ./mk04revocation-list.sh 
  usage: $ ./mk04revocation-list.sh 0|1 EnvFileName CertsFileName
          0: run.
          1: dryrun. rehearsal.
          EnvFileName: 'mk00Certificate_RoadWarrior'
          CertsFileName: 'Client Certificate.pem'
  ```
  ```bash
  root@strongswan01:# ./mk04revocation-list.sh 1 mk00Certificate_android-01_to_vpn-01_RSA ./clients/android-01.l2tp.local_ClientCert.pem 
  CA_KEY : ./private/MyCaKey_strongSwan.local.pem
  CA_CERT: ./cacerts/MyCaCert_strongSwan.local.pem
  REVOCATION_CLIENT_CERT: ./clients/android-01.l2tp.local_ClientCert.pem
  REVOCATION_LIST: ./clients/android-01.l2tp.local_ClientCert_crl.pem
  ```
  ```bash
  root@strongswan01:# ./mk04revocation-list.sh 0 mk00Certificate_android-01_to_vpn-01_RSA ./clients/android-01.l2tp.local_ClientCert.pem
  CA_KEY : ./private/MyCaKey_strongSwan.local.pem
  CA_CERT: ./cacerts/MyCaCert_strongSwan.local.pem
  REVOCATION_CLIENT_CERT: ./clients/android-01.l2tp.local_ClientCert.pem
  REVOCATION_LIST: ./clients/android-01.l2tp.local_ClientCert_crl.pem
  ipsec pki --signcrl --cacert ./cacerts/MyCaCert_strongSwan.local.pem ...
  root@strongswan01:# ls -l ./clients/android-01.l2tp.local_ClientCert{,_crl}.pem
  -rw-r--r-- 1 root root 2037 Oct  4 11:31 ./clients/android-01.l2tp.local_ClientCert.pem
  -rw-r--r-- 1 root root 1125 Oct  4 11:58 ./clients/android-01.l2tp.local_ClientCert_crl.pem
  ```

## Archive
- Server Key and Server Certification and CA Certification
  ```bash
  $ cd /var/opt/docker.volume/strongswan01/strongswan.certs/
  $ sudo ls -l ./{cacerts,certs,private}/
  $ sudo tar -C ../ -cpf ./srvKey-srvCert_CaCert_vpn-02.kvm0242.global.tar \
  > ./strongswan.certs/{\
  > cacerts/MyCaCert_strongSwan.local.pem,\
  > certs/SrvCert_vpn-02.kvm0242.global.pem,\
  > private/SrvKey_vpn-02.kvm0242.global.pem\
  > }
  $ tar -tvpf ./srvKey-srvCert_CaCert_vpn-02.kvm0242.global.tar
  -rw-r--r-- root/root      2021 2020-10-03 15:16 ./strongswan.certs/cacerts/MyCaCert_strongSwan.local.pem
  -rw-r--r-- root/root      2061 2020-10-03 15:35 ./strongswan.certs/certs/SrvCert_vpn-02.kvm0242.global.pem
  -rw------- root/root      3247 2020-10-03 15:35 ./strongswan.certs/private/SrvKey_vpn-02.kvm0242.global.pem
  ```
- Example
  ```bash
  $ ssh -i ~/.ssh/id_ed25519 -l devel 172.31.242.251 mkdir -p ./Work/config/
  $ scp -i ~/.ssh/id_ed25519 ./srvKey-srvCert_CaCert_vpn-02.kvm0242.global.tar \
  > devel@172.31.242.251:~/Work/config/
  ```

---

## VPN Server

- Remote Login
  ```bash
  $ hostname -s
  docker-02
  ```
- Extract
  ```bash
  $ cd ~/Work/config
  $ sudo tar -xpf ./srvKey-srvCert_CaCert_vpn-02.kvm0242.global.tar
  $ cd ./strongswan.certs/
  $ ls -lR
  ```
- Set files
  ```bash
  $ sudo ls -l /var/opt/docker.volume/strongswan02/ipsec.d/{cacerts,certs,private}/
  $ sudo cp -ip {.,/var/opt/docker.volume/strongswan02/ipsec.d/}/cacerts/MyCaCert_strongSwan.local.pem
  $ sudo cp -ip {.,/var/opt/docker.volume/strongswan02/ipsec.d/}/certs/SrvCert_vpn-02.kvm0242.global.pem
  $ sudo cp -ip {.,/var/opt/docker.volume/strongswan02/ipsec.d/}/private/SrvKey_vpn-02.kvm0242.global.pem
  $ cd ..
  $ sudo rm -rf strongswan.certs
  ```
- Check files
  ```bash
  $ sudo docker-compose exec strongswan ls -l /etc/ipsec.d/{cacerts,certs,private}/
  /etc/ipsec.d/cacerts/:
  total 4
  -rw-r--r-- 1 root root 2021 Oct  3 15:16 MyCaCert_strongSwan.local.pem
  
  /etc/ipsec.d/certs/:
  total 4
  -rw-r--r-- 1 root root 2061 Oct  3 15:35 SrvCert_vpn-02.kvm0242.global.pem
  
  /etc/ipsec.d/private/:
  total 4
  -rw------- 1 root root 3247 Oct  3 15:35 SrvKey_vpn-02.kvm0242.global.pem
  ```
