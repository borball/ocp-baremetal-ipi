#!/bin/bash

ASSETS_PATH=${BASEDIR}/assets
CLUSTER_PATH=${BASEDIR}/${cluster_name}

if [[ -z ${ASSETS_PATH}/install-config.yaml ]]
then
  echo "Could not find install-config.yaml in folder ${ASSETS_PATH}, something must be wrong."
  exit 1
fi

rm -rf ${CLUSTER_PATH}
mkdir -p ${CLUSTER_PATH}/openshift
cp ${ASSETS_PATH}/install-config.yaml ${CLUSTER_PATH}/install-config.yaml

${BIN_PATH}/openshift-baremetal-install --dir ${CLUSTER_PATH} --log-level debug create manifests

cp ${ASSETS_PATH}/MC/* ${CLUSTER_PATH}/openshift/

${BIN_PATH}/openshift-baremetal-install --dir ${CLUSTER_PATH} --log-level debug create cluster

source ~/.bash_profile

oc get clusterversion
