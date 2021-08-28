#!/bin/bash

BIN_PATH=${HELPER_NODE_PATH}/bin
TEMP_PATH=${HELPER_NODE_PATH}/temp
LOCAL_SECRET_JSON=${BASEDIR}/pull_secret.json

mkdir -p ${BIN_PATH} ${TEMP_PATH}

if [ ! -f ${TEMP_PATH}/oc-client.tar.gz ]
then
  curl -L https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/openshift-client-linux.tar.gz -o ${TEMP_PATH}/oc-client.tar.gz
  tar xfz ${TEMP_PATH}/oc-client.tar.gz oc
  mv ./oc ${BIN_PATH}/
fi

RELEASE_IMAGE=$(curl -s https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/release.txt | grep 'Pull From: quay.io' | awk -F ' ' '{print $3}')

${BIN_PATH}/oc adm release extract --registry-config $LOCAL_SECRET_JSON --command=openshift-baremetal-install --to ${BIN_PATH} $RELEASE_IMAGE

