#!/bin/bash

cp ${BASEDIR}/pull_secret.json ${HELPER_NODE_PATH}/assets/
cp ${BASEDIR}/pull_secret.json ${HELPER_NODE_PATH}/
cp ${BASEDIR}/config.cfg ${HELPER_NODE_PATH}/

rsync -a ${HELPER_NODE_PATH}/ 192.168.10.100:/root/${cluster_name}-installer
