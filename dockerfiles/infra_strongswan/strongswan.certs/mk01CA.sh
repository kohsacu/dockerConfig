#!/bin/bash

source ${2:-mk00Certificate}

DEBUG=1
DRYRUN=${1:-1}

if [ ${DEBUG} -ge 1 ]; then
    echo "CA_KEY : ${CA_KEY}"
    echo "CA_CERT: ${CA_CERT}"
    #
    #
    # == Padding ==
    #
    #
fi

if [ ${DRYRUN} -eq 0 ]; then
    mkdir -p ./private ./cacerts
    chmod 700 ./private
    if [ -f ${CA_KEY} ]; then
        echo "${CA_KEY} is exists."
    else
        echo "\$ openssl genrsa -out ${CA_KEY} ${KEY_LEN}"
        openssl genrsa -out ${CA_KEY} ${KEY_LEN}
        echo "\$ chmod 600 ${CA_KEY}"
        chmod 600 ${CA_KEY}
    fi

    if [ -f ${CA_CERT} ]; then
        echo "${CA_CERT} is exists."
    else
        echo "\$ ipsec pki --self --ca --lifetime ${CA_LIFE_TIME} ..."
        ipsec pki --self --ca --lifetime ${CA_LIFE_TIME} \
          --in ${CA_KEY} --type rsa \
          --dn "C=${COUNTRY_NAME}, ST=${STATE_NAME}, L=${CA_LOCALITY_NAME}, O=${ORG_NAME}, OU=${CA_ORG_UNIT_NAME}, CN=${CA_COMMON_NAME}" \
          --digest sha256 \
          --outform pem \
          > ${CA_CERT}
    fi
fi
