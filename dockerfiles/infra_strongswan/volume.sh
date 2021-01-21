#!/usr/bin/env sh

# environment variable
. ./.env

# startup scripts
sudo mkdir -p "${PATH_DOCKER_VOLUME}/${CONTAINER}/init.d"
sudo cp -i ./files/init.d/10-strongswan.sh \
              "${PATH_DOCKER_VOLUME}/${CONTAINER}/init.d/"

# strongSwan drop-in files
for dir in aacerts acerts cacerts certs clients crls ocspcerts policies private reqs
do
    sudo mkdir -p "${PATH_DOCKER_VOLUME}/${CONTAINER}/ipsec.d/${dir}"
done
sudo chmod 0700 "${PATH_DOCKER_VOLUME}/${CONTAINER}/ipsec.d/private"
sudo cp -i ./files/ipsec.d/ipsec_RSA.secrets \
           ./files/ipsec.d/ipsec_EAP.secrets \
	        "${PATH_DOCKER_VOLUME}/${CONTAINER}/ipsec.d/"
sudo chmod 0600 "${PATH_DOCKER_VOLUME}/${CONTAINER}/ipsec.d/ipsec_*.secrets"

# strongSwan drop-in files
sudo mkdir -p "${PATH_DOCKER_VOLUME}/${CONTAINER}/strongswan.d/charon"
sudo cp -i ./files/strongswan.d/charon/kernel-netlink.conf \
	      "${PATH_DOCKER_VOLUME}/${CONTAINER}/strongswan.d/charon/"

# strongSwan certification scripts
sudo cp -iR ./strongswan.certs "${PATH_DOCKER_VOLUME}/${CONTAINER}"

