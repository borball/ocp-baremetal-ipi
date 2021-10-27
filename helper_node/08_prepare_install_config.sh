#!/bin/bash

cp -f ${ASSETS_PATH}/install-config-template.yaml ${ASSETS_PATH}/install-config.yaml

INSTALL_CONFIG_FILE=${ASSETS_PATH}/install-config.yaml

sed -i "s|EXTERNAL_BRIDGE|${network_name}|" ${INSTALL_CONFIG_FILE}
sed -i "s|BASEDOMAIN|${base_domain}|" ${INSTALL_CONFIG_FILE}
sed -i "s|CLUSTERNAME|${cluster_name}|" ${INSTALL_CONFIG_FILE}

# Get redfish endpoints for every node
for node in master0 master1 master2
do
  VMID=$(ssh 192.168.10.1 kcli info vm ${cluster_name}-${node} -f id -v)
  sed -i "s/${node}id/${VMID}/" ${INSTALL_CONFIG_FILE}
done

OPENSTACK_IMAGE=$(${BIN_PATH}/openshift-baremetal-install coreos print-stream-json | jq '.architectures.x86_64.artifacts.openstack.formats."qcow2.gz".disk.location' | tr -d '"')
QEMU_IMAGE=$(${BIN_PATH}/openshift-baremetal-install coreos print-stream-json | jq '.architectures.x86_64.artifacts.qemu.formats."qcow2.gz".disk.location' | tr -d '"')
OPENSTACK_IMAGE_FILE=$(basename ${OPENSTACK_IMAGE} | tr -d '"')
QEMU_IMAGE_FILE=$(basename ${QEMU_IMAGE} | tr -d '"')
# Openstack requires compressed sha
OPENSTACK_IMAGE_SHA256=$(${BIN_PATH}/openshift-baremetal-install coreos print-stream-json | jq '.architectures.x86_64.artifacts.openstack.formats."qcow2.gz".disk.sha256' | tr -d '"')
# Qemu requires uncompressed sha
QEMU_IMAGE_UNCOMPRESSED_SHA256=$(${BIN_PATH}/openshift-baremetal-install coreos print-stream-json | jq '.architectures.x86_64.artifacts.qemu.formats."qcow2.gz".disk."uncompressed-sha256"' | tr -d '"')

sed -i "s/QEMUIMAGE/${QEMU_IMAGE_FILE}?sha256=${QEMU_IMAGE_UNCOMPRESSED_SHA256}/" ${INSTALL_CONFIG_FILE}
sed -i "s/OSTACKIMAGE/${OPENSTACK_IMAGE_FILE}?sha256=${OPENSTACK_IMAGE_SHA256}/" ${INSTALL_CONFIG_FILE}


sed -i "s|SSHPUBKEY|$(cat ~/.ssh/id_rsa.pub)|" ${INSTALL_CONFIG_FILE}
sed -i "s/REGISTRYHOSTNAME/$(hostname -f)/" ${INSTALL_CONFIG_FILE}

sed -i '/REGISTRYCA/e cat /opt/registry/certs/domain.crt | sed "s/^/  /"' ${INSTALL_CONFIG_FILE}
sed -i '/REGISTRYCA/d' ${INSTALL_CONFIG_FILE}

podman login $(hostname -f):5000 -u kni -p kni --authfile /tmp/tempauth &> /dev/null
sed -i "s|PULLSECRET|$(cat /tmp/tempauth | jq '.' -c)|" ${INSTALL_CONFIG_FILE}
rm /tmp/tempauth
