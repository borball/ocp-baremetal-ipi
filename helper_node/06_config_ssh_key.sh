#!/bin/bash

INSTALL_CONFIG_FILE=${BASEDIR}/assets/install-config.yaml

sed -i "s|SSHPUBKEY|$(cat ~/.ssh/id_rsa.pub)|" ${INSTALL_CONFIG_FILE}
