#!/bin/sh -x

DEFAULT_VIA="172.18.0.1"
ROUTER_ID_IF="loopback0"
REDUNDANT_IF="redundant0"
REDUNDANT_ADDR_A="203.0.113.1/32"
REDUNDANT_ADDR_B="203.0.113.2/32"
ROUTER_ID_ADDR_A_0="203.0.113.10/32"
ROUTER_ID_ADDR_A_1="203.0.113.11/32"
ROUTER_ID_ADDR_B_0="203.0.113.12/32"
ROUTER_ID_ADDR_B_1="203.0.113.13/32"

CON_NAME="bird-A-0"
sudo docker container exec -it ${CON_NAME} ip route delete default
sudo docker container exec -it ${CON_NAME} ip route add default via ${DEFAULT_VIA}
#
sudo docker container exec -it ${CON_NAME} ip link add ${ROUTER_ID_IF} type dummy
sudo docker container exec -it ${CON_NAME} ip addr add ${ROUTER_ID_ADDR_A_0} dev ${ROUTER_ID_IF}
sudo docker container exec -it ${CON_NAME} ip link set ${ROUTER_ID_IF} up
#
sudo docker container exec -it ${CON_NAME} ip link add ${REDUNDANT_IF} type dummy
sudo docker container exec -it ${CON_NAME} ip addr add ${REDUNDANT_ADDR_A} dev ${REDUNDANT_IF}
sudo docker container exec -it ${CON_NAME} ip link set ${REDUNDANT_IF} up

CON_NAME="bird-A-1"
sudo docker container exec -it ${CON_NAME} ip route delete default
sudo docker container exec -it ${CON_NAME} ip route add default via ${DEFAULT_VIA}
#
sudo docker container exec -it ${CON_NAME} ip link add ${ROUTER_ID_IF} type dummy
sudo docker container exec -it ${CON_NAME} ip addr add ${ROUTER_ID_ADDR_A_1} dev ${ROUTER_ID_IF}
sudo docker container exec -it ${CON_NAME} ip link set ${ROUTER_ID_IF} up
#
sudo docker container exec -it ${CON_NAME} ip link add ${REDUNDANT_IF} type dummy
sudo docker container exec -it ${CON_NAME} ip addr add ${REDUNDANT_ADDR_A} dev ${REDUNDANT_IF}
sudo docker container exec -it ${CON_NAME} ip link set ${REDUNDANT_IF} up

CON_NAME="bird-B-0"
sudo docker container exec -it ${CON_NAME} ip route delete default
sudo docker container exec -it ${CON_NAME} ip route add default via ${DEFAULT_VIA}
#
sudo docker container exec -it ${CON_NAME} ip link add ${ROUTER_ID_IF} type dummy
sudo docker container exec -it ${CON_NAME} ip addr add ${ROUTER_ID_ADDR_B_0} dev ${ROUTER_ID_IF}
sudo docker container exec -it ${CON_NAME} ip link set ${ROUTER_ID_IF} up
#
sudo docker container exec -it ${CON_NAME} ip link add ${REDUNDANT_IF} type dummy
sudo docker container exec -it ${CON_NAME} ip addr add ${REDUNDANT_ADDR_B} dev ${REDUNDANT_IF}
sudo docker container exec -it ${CON_NAME} ip link set ${REDUNDANT_IF} up

CON_NAME="bird-B-1"
sudo docker container exec -it ${CON_NAME} ip route delete default
sudo docker container exec -it ${CON_NAME} ip route add default via ${DEFAULT_VIA}
#
sudo docker container exec -it ${CON_NAME} ip link add ${ROUTER_ID_IF} type dummy
sudo docker container exec -it ${CON_NAME} ip addr add ${ROUTER_ID_ADDR_B_1} dev ${ROUTER_ID_IF}
sudo docker container exec -it ${CON_NAME} ip link set ${ROUTER_ID_IF} up
#
sudo docker container exec -it ${CON_NAME} ip link add ${REDUNDANT_IF} type dummy
sudo docker container exec -it ${CON_NAME} ip addr add ${REDUNDANT_ADDR_B} dev ${REDUNDANT_IF}
sudo docker container exec -it ${CON_NAME} ip link set ${REDUNDANT_IF} up

