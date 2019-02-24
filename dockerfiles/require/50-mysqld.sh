#!/bin/bash

#MYSQL_ROOT_PASSWORD='mysql_secret'
DATADIR="$(mysqld --verbose --help 2>/dev/null | awk '$1 == "datadir" { print $2; exit }')"
MYSQL_TAR_FILE="/root/mysqld_datadir_1st.tar.gz"

if [ ! -d "${DATADIR}/mysql" ]; then
    echo 'Initializing database...'
    mkdir -p "${DATADIR}"
    #sudo -u mysql mysql_install_db --datadir=${DATADIR} --user=mysql
    tar -C ${DATADIR}/.. -zxpf ${MYSQL_TAR_FILE}
    chown -R mysql:mysql "${DATADIR}"
    echo 'Database initialized.'
else
    /etc/init.d/mysql start
fi
