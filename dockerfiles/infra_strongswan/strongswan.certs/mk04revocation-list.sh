#!/bin/bash

source ${2:-mk00Certificate}

DEBUG=1
DRYRUN=${1:-1}

if [ ! -z ${3} ]; then
    REV_CLIENT_CERT=${3}
   #REVOCATION_LIST="${CA_ORG_UNIT_NAME}.${LFQDN}_crl.pem"
    REVOCATION_LIST=${REV_CLIENT_CERT%.pem}_crl.pem
else
    echo "usage: \$ ${0} 0|1 EnvFileName CertsFileName"
    echo -e "\t0: run."
    echo -e "\t1: dryrun. rehearsal."
    echo -e "\tEnvFileName: 'mk00Certificate_RoadWarrior'"
    echo -e "\tCertsFileName: 'Client Certificate.pem'"
    exit 1
fi

if [ ${DEBUG} -ge 1 ]; then
    echo "CA_KEY : ${CA_KEY}"
    echo "CA_CERT: ${CA_CERT}"
    echo "REVOCATION_CLIENT_CERT: ${REV_CLIENT_CERT}"
    echo "REVOCATION_LIST: ${REVOCATION_LIST}"
fi

if [ ${DRYRUN} -eq 0 ]; then
    echo "ipsec pki --signcrl --cacert ${CA_CERT} ..."
    ipsec pki --signcrl --cacert ${CA_CERT} \
      --cakey ${CA_KEY} \
      --reason superseded \
      --cert ${REV_CLIENT_CERT} \
      --digest sha256 \
      --outform pem \
      > ${REVOCATION_LIST}
fi
