#!/bin/sh

DEFAULT_VIA="172.18.0.1"
REDUNDANT_IF_0="redundant0"
GRE_TUN_IF_0="gre-redun0"
GRE_OUTER_ADDR_A="10.10.10.1"
GRE_OUTER_ADDR_B="10.10.10.2"
GRE_OUTER_ADDR_C="10.10.10.3"
GRE_INNER_ADDR_B="10.10.40.1"

# # == bird-A-0 ==
# ip route delete default
# ip route add default via "${DEFAULT_VIA}"
# 
# ip link add "${REDUNDANT_IF}" type dummy
# ip addr add "${GRE_OUTER_ADDR_A}/32" dev "${REDUNDANT_IF}"
# ip link set "${REDUNDANT_IF}" up
# 
# ip tunnel add "${GRE_TUN_IF_0}" mode gre remote "${GRE_OUTER_ADDR_B}" local "${GRE_OUTER_ADDR_A}"
# ip link set "${GRE_TUN_IF_0}" up
# 
# # == bird-A-1 ==
# ip route delete default
# ip route add default via "${DEFAULT_VIA}"
# 
# ip link add "${REDUNDANT_IF}" type dummy
# ip addr add "${GRE_OUTER_ADDR_A}/32" dev "${REDUNDANT_IF}"
# ip link set "${REDUNDANT_IF}" up
# 
# ip tunnel add "${GRE_TUN_IF_0}" mode gre remote "${GRE_OUTER_ADDR_B}" local "${GRE_OUTER_ADDR_A}"
# ip link set "${GRE_TUN_IF_0}" up
# 
# # == bird-B-0 ==
# ip route delete default
# ip route add default via "${DEFAULT_VIA}"
# 
# ip link add "${REDUNDANT_IF}" type dummy
# ip addr add "${GRE_OUTER_ADDR_B}/32" dev "${REDUNDANT_IF}"
# ip link set "${REDUNDANT_IF}" up
# 
# ip tunnel add "${GRE_TUN_IF_0}" mode gre remote "${GRE_OUTER_ADDR_A}" local "${GRE_OUTER_ADDR_B}"
# ip addr add "${GRE_INNER_ADDR_B}/24" dev "${GRE_TUN_IF_0}"
# ip link set "${GRE_TUN_IF_0}" up
# 
# # == bird-B-1 ==
# ip route delete default
# ip route add default via "${DEFAULT_VIA}"
# 
# ip link add "${REDUNDANT_IF}" type dummy
# ip addr add "${GRE_OUTER_ADDR_B}/32" dev "${REDUNDANT_IF}"
# ip link set "${REDUNDANT_IF}" up
# 
# ip tunnel add "${GRE_TUN_IF_0}" mode gre remote "${GRE_OUTER_ADDR_A}" local "${GRE_OUTER_ADDR_B}"
# ip addr add "${GRE_INNER_ADDR_B}/24" dev "${GRE_TUN_IF_0}"
# ip link set "${GRE_TUN_IF_0}" up
# 
# # == bird-ToR-0/1 ==
# ip route delete default
# ip route add default via "${DEFAULT_VIA}"
# 
# ip link add "${REDUNDANT_IF}" type dummy
# ip addr add "${GRE_OUTER_ADDR_C}/32" dev "${REDUNDANT_IF}"
# ip link set "${REDUNDANT_IF}" up

