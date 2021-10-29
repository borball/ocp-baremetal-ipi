#!/bin/bash

BIN_PATH=${HELPER_NODE_PATH}/bin
TEMP_PATH=${HELPER_NODE_PATH}/temp
LOCAL_SECRET_JSON=${BASEDIR}/pull_secret.json

rm -rf ${BIN_PATH} ${TEMP_PATH}
mkdir -p ${BIN_PATH} ${TEMP_PATH}

if [ ! -f ${TEMP_PATH}/oc-client.tar.gz ]
then
  curl -L https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OCP_RELEASE_FULL}/openshift-client-linux.tar.gz -o ${TEMP_PATH}/oc-client.tar.gz
  tar xfz ${TEMP_PATH}/oc-client.tar.gz oc
  mv ./oc ${BIN_PATH}/
fi

if [ ! -f ${TEMP_PATH}/opm-linux.tar.gz ]
then
  curl -L https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OCP_RELEASE_FULL}/opm-linux.tar.gz -o ${TEMP_PATH}/opm-linux.tar.gz
  tar xfz ${TEMP_PATH}/opm-linux.tar.gz opm
  mv ./opm ${BIN_PATH}/
fi

${BIN_PATH}/oc adm release extract --registry-config $LOCAL_SECRET_JSON --command=openshift-baremetal-install --to ${BIN_PATH} $OCP_RELEASE_FULL

