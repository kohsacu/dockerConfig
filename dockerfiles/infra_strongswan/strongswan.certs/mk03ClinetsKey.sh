#!/bin/bash

source ${2:-mk00Certificate}

DEBUG=1
DRYRUN=${1:-1}

if [ ${DEBUG} -ge 1 ]; then
    echo "CA_KEY : ${CA_KEY}"
    echo "CA_CERT: ${CA_CERT}"
    echo "CLIENT_KEY : ${CLIENT_KEY}"
    echo "CLIENT_CERT: ${CLIENT_CERT}"
    echo "CLIENT_LOCALITY_NAME: ${CLIENT_LOCALITY_NAME}"
    echo "CLIENT_ORG_UNIT_NAME: ${CLIENT_ORG_UNIT_NAME}"
    echo "CLIENT_CN: ${CLIENT_CN}"
fi

if [ ${DRYRUN} -eq 0 ]; then
    mkdir -p ./clients

    if [ -f ./clients/${CLIENT_KEY} ]; then
        echo "./clients/${CLIENT_KEY} is exists."
    else
        #ipsec pki --gen --type rsa --size 2048 --outform pem > $CLIENT_KEY 
        echo "\$ openssl genrsa -out ./clients/${CLIENT_KEY} ${KEY_LEN}"
        openssl genrsa -out ./clients/${CLIENT_KEY} ${KEY_LEN}
    fi

    if [ -f ./clients/${CLIENT_CERT} ]; then
        echo "./clients/${CLIENT_CERT} is exists."
    else
        echo "\$ ipsec pki --pub --in ./clients/${CLIENT_KEY} --type rsa ..."
        ipsec pki --pub --in ./clients/${CLIENT_KEY} --type rsa | \
            ipsec pki --issue --lifetime ${LIFE_TIME} \
            --cacert ${CA_CERT} \
            --cakey ${CA_KEY} \
            --dn "C=${COUNTRY_NAME}, ST=${STATE_NAME}, L=${CLIENT_LOCALITY_NAME}, O=${ORG_NAME}, OU=${CLIENT_ORG_UNIT_NAME}, CN=${CLIENT_CN}" \
            --san ${CLIENT_CN} \
            --digest sha256 \
            --outform pem > ./clients/${CLIENT_CERT}
    fi

    if [ -f ./clients/${CLIENT_CERT%.pem}.p12 ]; then
        echo "./clients/${CLIENT_CERT%.pem}.p12 is exists."
    else
        echo "\$ openssl pkcs12 -export -inkey ./clients/${CLIENT_KEY} ..."
        openssl pkcs12 -export -inkey ./clients/${CLIENT_KEY} \
            -in ./clients/${CLIENT_CERT} -name "${LHOST} VPN PKCS #12" \
            -certfile ${CA_CERT} \
            -caname "${CA_ORG_UNIT_NAME}" \
            -out ./clients/${CLIENT_CERT%.pem}.p12
    fi
fi
