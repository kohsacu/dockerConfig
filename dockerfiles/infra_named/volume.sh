#!/usr/bin/env sh

# environment variable
. ./.env
TYPE=${1}
if [ ${TYPE} = 'master' ]; then
    SRC_DIR='1.bind-master'
elif [ ${TYPE} = 'slave' ]; then
    SRC_DIR='2.bind-slave'
else
    echo "Usage: Arg 'master' or 'slave'"
    exit 1
fi

# bind9 drop-in files
sudo mkdir -p "${PATH_DOCKER_VOLUME}/${CONTAINER}/etc/bind"
sudo cp -ip ./files/"${SRC_DIR}"/etc/named.conf                "${PATH_DOCKER_VOLUME}/${CONTAINER}/etc/bind/"
sudo cp -ip ./files/"${SRC_DIR}"/etc/named.conf.internal-zones "${PATH_DOCKER_VOLUME}/${CONTAINER}/etc/bind/"
sudo cp -ip ./files/"${SRC_DIR}"/etc/named.conf.local          "${PATH_DOCKER_VOLUME}/${CONTAINER}/etc/bind/"
sudo cp -ip ./files/"${SRC_DIR}"/etc/named.conf.options        "${PATH_DOCKER_VOLUME}/${CONTAINER}/etc/bind/"

# bind9 Zone files
for dir in zones-master zones-slave
do
    sudo mkdir -p      "${PATH_DOCKER_VOLUME}/${CONTAINER}/var/cache/bind/${dir}"
done
sudo chmod -R 0775     "${PATH_DOCKER_VOLUME}/${CONTAINER}/var/cache/bind"
sudo chgrp -R 101      "${PATH_DOCKER_VOLUME}/${CONTAINER}/var/cache/bind"
sudo cp -ip ./files/1.bind-master/var/* "${PATH_DOCKER_VOLUME}/${CONTAINER}/var/cache/bind/zones-master/"

