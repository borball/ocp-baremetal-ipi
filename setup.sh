#!/bin/bash

export BASEDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [[ ! -f ${BASEDIR}/pull_secret.json ]]
then
  echo "You need to place the pull_secret.json file inside the ${BASEDIR} folder!"
  exit 1
fi

### Install basic tools start ###
dnf install -y libvirt libvirt-daemon-driver-qemu qemu-kvm git rsync jq
usermod -aG qemu,libvirt $(id -un)
systemctl enable --now libvirtd
dnf copr enable karmab/kcli -y
dnf install kcli -y
### Install basic tools end ###

source ${BASEDIR}/config.cfg

#ocp full version x.y.z, reading from https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OCP_RELEASE}/release.txt
export OCP_RELEASE_FULL=$(curl -s https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OCP_RELEASE}/release.txt | grep 'Version:' | awk -F ' ' '{print $2}')

export HELPER_NODE_PATH=${BASEDIR}/helper_node

${BASEDIR}/00_download_ocp.sh
${BASEDIR}/01_create_virt_network.sh
${BASEDIR}/02_create_helper_vm.sh
${BASEDIR}/03_create_empty_vms.sh

while [[ ! $(ssh -o BatchMode=yes -o ConnectTimeout=5 ${helper_node_ip} echo connected 2>&1) =~ "connected" ]]; do
	sleep 5
	echo "Waiting for helper node coming up..."
done

${BASEDIR}/04_helper_node_files.sh

ssh-keyscan -H ${helper_node_ip} >> ~/.ssh/known_hosts
ssh ${helper_node_ip} "ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1"
ssh ${helper_node_ip} "ssh-keyscan -H ${hypervisor}  >> ~/.ssh/known_hosts"
ssh -q ${helper_node_ip} "cat ~/.ssh/id_rsa.pub" >> ~/.ssh/authorized_keys

echo "----------------------------------------------------------------------"
echo
echo "Now you will be sshing to helper node ${helper_node_ip}."
echo "You can run commands below to start the OCP IPI deployment."
echo
echo "    cd /root/${cluster_name}-installer"
echo "    ./install.sh"
echo
echo "----------------------------------------------------------------------"

ssh ${helper_node_ip}

