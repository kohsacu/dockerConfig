#!/bin/bash

iptables --table filter --insert DOCKER-ISOLATION-STAGE-1 2 --in-interface  br_ctl0252 --destination 172.31.11.0/24  --jump ACCEPT
iptables --table filter --insert DOCKER-ISOLATION-STAGE-1 2 --in-interface  br_ctl0252 --destination 10.32.201.0/24  --jump ACCEPT
iptables --table filter --insert DOCKER-ISOLATION-STAGE-1 2 --out-interface br_ctl0252 --source      172.31.11.0/24  --jump ACCEPT
iptables --table filter --insert DOCKER-ISOLATION-STAGE-1 2 --out-interface br_ctl0252 --source      10.32.201.0/24  --jump ACCEPT

iptables --table filter --insert DOCKER-ISOLATION-STAGE-1 2 --in-interface  br_int0011 --destination 172.31.252.0/24 --jump ACCEPT
iptables --table filter --insert DOCKER-ISOLATION-STAGE-1 2 --in-interface  br_int0011 --destination 10.32.201.0/24  --jump ACCEPT
iptables --table filter --insert DOCKER-ISOLATION-STAGE-1 2 --out-interface br_int0011 --source      172.31.252.0/24 --jump ACCEPT
iptables --table filter --insert DOCKER-ISOLATION-STAGE-1 2 --out-interface br_int0011 --source      10.32.201.0/24  --jump ACCEPT

iptables --table filter --insert DOCKER-ISOLATION-STAGE-1 2 --in-interface  br_atk0201 --destination 172.31.252.0/24 --jump ACCEPT
iptables --table filter --insert DOCKER-ISOLATION-STAGE-1 2 --in-interface  br_atk0201 --destination 172.31.11.0/24  --jump ACCEPT
iptables --table filter --insert DOCKER-ISOLATION-STAGE-1 2 --out-interface br_atk0201 --source      172.31.252.0/24 --jump ACCEPT
iptables --table filter --insert DOCKER-ISOLATION-STAGE-1 2 --out-interface br_atk0201 --source      172.31.11.0/24  --jump ACCEPT
