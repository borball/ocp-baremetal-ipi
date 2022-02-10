#!/bin/bash

cp -f ${ASSETS_PATH}/install-config-template.yaml ${ASSETS_PATH}/install-config.yaml

sed -i "s|EXTERNAL_BRIDGE|${network_name}|" ${INSTALL_CONFIG_FILE}
sed -i "s|BASEDOMAIN|${base_domain}|" ${INSTALL_CONFIG_FILE}
sed -i "s|CLUSTERNAME|${cluster_name}|" ${INSTALL_CONFIG_FILE}
sed -i "s|PULLSECRET|$(cat ${BASEDIR}/pull_secret.json | jq '.' -c)|" ${INSTALL_CONFIG_FILE}

# Get redfish endpoints for every node
for node in master0 master1 master2
do
  VMID=$(kcli info vm ${cluster_name}-${node} -f id -v)
  sed -i "s/${node}id/${VMID}/" ${INSTALL_CONFIG_FILE}
done
