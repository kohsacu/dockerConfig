#!/bin/bash

source ${2:-mk00Certificate}

DEBUG=1
DRYRUN=${1:-1}

if [ ${DEBUG} -ge 1 ]; then
    echo "CA_KEY : ${CA_KEY}"
    echo "CA_CERT: ${CA_CERT}"
    echo "SERVER_KEY:  ${SERVER_KEY}"
    echo "SERVER_CERT: ${SERVER_CERT}"
    echo "GFQDN: ${GFQDN}"
    #
    # == Padding ==
fi

if [ ${DRYRUN} -eq 0 ]; then
    mkdir -p ./private ./certs
    chmod 700 ./private
    if [ -f ${SERVER_KEY} ]; then
        echo "${SERVER_KEY} is exists."
    else
        echo "\$ openssl genrsa -out ${SERVER_KEY} ${KEY_LEN}"
        openssl genrsa -out ${SERVER_KEY} ${KEY_LEN}
        echo "\$ chmod 600 ${SERVER_KEY}"
        chmod 600 ${SERVER_KEY}
    fi

    if [ -f ${SERVER_CERT} ]; then
        echo "${SERVER_CERT} is exists."
    else
        echo "\$ ipsec pki --pub --in ${SERVER_KEY} --type rsa ..."
        ipsec pki --pub --in ${SERVER_KEY} --type rsa  | ipsec pki \
          --issue --lifetime ${LIFE_TIME} \
          --cacert ${CA_CERT} --cakey ${CA_KEY} \
          --dn "C=${COUNTRY_NAME}, ST=${STATE_NAME}, L=${CA_LOCALITY_NAME}, O=${ORG_NAME}, OU=${SERVER_ORG_UNIT_NAME}, CN=${GFQDN}" \
          --digest sha256 --san ${GFQDN} \
          --flag serverAuth --flag ikeIntermediate \
          --outform pem \
          > ${SERVER_CERT}
    fi
fi
