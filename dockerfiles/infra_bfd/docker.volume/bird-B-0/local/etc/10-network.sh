#!/bin/sh

#DEFAULT_VIA="172.18.0.1"
#REDUNDANT_IF="redundant0"
#GRE_TUN_IF_0="gre-redun0"
#GRE_OUTER_ADDR_A="10.10.10.1"
#GRE_OUTER_ADDR_B="10.10.10.129"
#GRE_INNER_NW_A01="100.64.0.0/24"
#GRE_INNER_NW_A02="10.10.30.0/24"
#GRE_INNER_NW_B01="10.100.1.0/24"

ip route delete default
#ip route add default via "${DEFAULT_VIA}"
#ip route add default dev ${GRE_TUN_IF_0}

#ip link add "${REDUNDANT_IF}" type dummy
#ip addr add "${GRE_OUTER_ADDR_B}/32" dev "${REDUNDANT_IF}"
#ip link set "${REDUNDANT_IF}" up
#
#ip tunnel add "${GRE_TUN_IF_0}" mode gre remote "${GRE_OUTER_ADDR_A}" local "${GRE_OUTER_ADDR_B}"
#ip link set "${GRE_TUN_IF_0}" up

#ip route add ${GRE_INNER_NW_A01} dev ${GRE_TUN_IF_0}
#ip route add ${GRE_INNER_NW_A02} dev ${GRE_TUN_IF_0}

