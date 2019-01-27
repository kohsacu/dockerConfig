#!/bin/bash

IPT='/sbin/iptables'

${IPT} --table filter --new-chain DOCKER-USER
${IPT} --table filter --append DOCKER-USER --in-interface  ${BR_INT0011_IF} --destination ${BR_ATK0201_PFIX} --jump ACCEPT
${IPT} --table filter --append DOCKER-USER --out-interface ${BR_INT0011_IF} --source      ${BR_ATK0201_PFIX} --jump ACCEPT
${IPT} --table filter --append DOCKER-USER --in-interface  ${BR_ATK0201_IF} --destination ${BR_INT0011_PFIX} --jump ACCEPT
${IPT} --table filter --append DOCKER-USER --out-interface ${BR_ATK0201_IF} --source      ${BR_INT0011_PFIX} --jump ACCEPT
#### for Routing Plane
${IPT} --table filter --append DOCKER-USER --in-interface  ${BR_RTZ0001_IF} --destination ${BR_INT0011_PFIX} --jump ACCEPT
${IPT} --table filter --append DOCKER-USER --in-interface  ${BR_RTZ0002_IF} --destination ${BR_INT0011_PFIX} --jump ACCEPT
${IPT} --table filter --append DOCKER-USER --in-interface  ${BR_RTZ0001_IF} --destination ${BR_ATK0201_PFIX} --jump ACCEPT
${IPT} --table filter --append DOCKER-USER --in-interface  ${BR_RTZ0002_IF} --destination ${BR_ATK0201_PFIX} --jump ACCEPT
## Logging(No Drop)
### DOCKER-USER
${IPT} --new-chain LOG_DOCKER-USER
${IPT} --append LOG_DOCKER-USER --jump LOG --log-level warning --log-prefix "[iptables: Docker-User]: "
${IPT} --append LOG_DOCKER-USER --jump RETURN
${IPT} --append DOCKER-USER --jump LOG_DOCKER-USER
