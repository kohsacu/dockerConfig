#!/bin/sh

#BASE_NAME=$(basename $0 .sh)
BASE_NAME="90-http.server"
BASE_DIR="/var/tmp"
ROOT_DIR="${BASE_DIR}/${BASE_NAME}"

mkdir -p  ${ROOT_DIR}
cd  ${ROOT_DIR}

hostname -s > hostname

python3.6 -m http.server 8000 &
