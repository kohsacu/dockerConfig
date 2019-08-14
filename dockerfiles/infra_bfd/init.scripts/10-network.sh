#!/bin/sh

DEFAULT_VIA="172.18.0.1"
ROUTER_ID_IF="loopback0"
REDUNDANT_IF="redundant0"
ROUTER_ID_ADDR_A_0="203.0.113.10"
ROUTER_ID_ADDR_A_1="203.0.113.11"
ROUTER_ID_ADDR_B_0="203.0.113.12"
ROUTER_ID_ADDR_B_1="203.0.113.13"
GRE_TUN_IF_0="gre-redun0"
GRE_OUTER_ADDR_A_0="203.0.113.64"
GRE_OUTER_ADDR_B_0="203.0.113.65"
GRE_INNER_ADDR_A_0="203.0.113.66"
GRE_INNER_ADDR_B_0="203.0.113.67"

# # == bird-A-0 ==
# ip route delete default
# ip route add default via "${DEFAULT_VIA}"
# 
# ip link add "${ROUTER_ID_IF}" type dummy
# ip addr add "${ROUTER_ID_ADDR_A_0}/32" dev "${ROUTER_ID_IF}"
# ip link set "${ROUTER_ID_IF}" up
# 
# ip link add "${REDUNDANT_IF}" type dummy
# ip addr add "${GRE_OUTER_ADDR_A_0}/32" dev "${REDUNDANT_IF}"
# ip link set "${REDUNDANT_IF}" up
# 
# ip tunnel add "${GRE_TUN_IF_0}" mode gre remote "${GRE_OUTER_ADDR_B_0}" local "${GRE_OUTER_ADDR_A_0}"
# ip addr add "${GRE_INNER_ADDR_A_0}/31" dev "${GRE_TUN_IF_0}"
# ip link set "${GRE_TUN_IF_0}" up
# 
# # == bird-A-1 ==
# ip route delete default
# ip route add default via "${DEFAULT_VIA}"
# 
# ip link add "${ROUTER_ID_IF}" type dummy
# ip addr add "${ROUTER_ID_ADDR_A_1}/32" dev "${ROUTER_ID_IF}"
# ip link set "${ROUTER_ID_IF}" up
# 
# ip link add "${REDUNDANT_IF}" type dummy
# ip addr add "${GRE_OUTER_ADDR_A_0}/32" dev "${REDUNDANT_IF}"
# ip link set "${REDUNDANT_IF}" up
# 
# ip tunnel add "${GRE_TUN_IF_0}" mode gre remote "${GRE_OUTER_ADDR_B_0}" local "${GRE_OUTER_ADDR_A_0}"
# ip addr add "${GRE_INNER_ADDR_A_0}/31" dev "${GRE_TUN_IF_0}"
# ip link set "${GRE_TUN_IF_0}" up
# 
# # == bird-B-0 ==
# ip route delete default
# ip route add default via "${DEFAULT_VIA}"
# 
# ip link add "${ROUTER_ID_IF}" type dummy
# ip addr add "${ROUTER_ID_ADDR_B_0}/32" dev "${ROUTER_ID_IF}"
# ip link set "${ROUTER_ID_IF}" up
# 
# ip link add "${REDUNDANT_IF}" type dummy
# ip addr add "${GRE_OUTER_ADDR_B_0}/32" dev "${REDUNDANT_IF}"
# ip link set "${REDUNDANT_IF}" up
# 
# ip tunnel add "${GRE_TUN_IF_0}" mode gre remote "${GRE_OUTER_ADDR_A_0}" local "${GRE_OUTER_ADDR_B_0}"
# ip addr add "${GRE_INNER_ADDR_B_0}/31" dev "${GRE_TUN_IF_0}"
# ip link set "${GRE_TUN_IF_0}" up
# 
# # == bird-B-1 ==
# ip route delete default
# ip route add default via "${DEFAULT_VIA}"
# 
# ip link add "${ROUTER_ID_IF}" type dummy
# ip addr add "${ROUTER_ID_ADDR_B_1}/32" dev "${ROUTER_ID_IF}"
# ip link set "${ROUTER_ID_IF}" up
# 
# ip link add "${REDUNDANT_IF}" type dummy
# ip addr add "${GRE_OUTER_ADDR_B_0}/32" dev "${REDUNDANT_IF}"
# ip link set "${REDUNDANT_IF}" up
# 
# ip tunnel add "${GRE_TUN_IF_0}" mode gre remote "${GRE_OUTER_ADDR_A_0}" local "${GRE_OUTER_ADDR_B_0}"
# ip addr add "${GRE_INNER_ADDR_B_0}/31" dev "${GRE_TUN_IF_0}"
# ip link set "${GRE_TUN_IF_0}" up

