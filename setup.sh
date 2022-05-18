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

export HELPER_NODE_PATH=${BASEDIR}/helper_node
export ASSETS_PATH=${HELPER_NODE_PATH}/assets
export INSTALL_CONFIG_FILE=${ASSETS_PATH}/install-config.yaml

${BASEDIR}/00_download_ocp.sh
#${BASEDIR}/01_create_virt_network.sh
${BASEDIR}/02_create_helper_vm.sh
${BASEDIR}/03_create_empty_vms.sh
${BASEDIR}/04_init_install_config.sh

while [[ ! $(ssh -o BatchMode=yes -o ConnectTimeout=5 192.168.58.100 echo connected 2>&1) =~ "connected" ]]; do
	sleep 5
	echo "Waiting for helper node coming up..."
done

${BASEDIR}/05_helper_node_files.sh

ssh-keyscan -H 192.168.58.100 >> ~/.ssh/known_hosts
ssh 192.168.58.100 "ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1"
ssh 192.168.58.100 "ssh-keyscan -H 192.168.58.1  >> ~/.ssh/known_hosts"
ssh -q 192.168.58.100 "cat ~/.ssh/id_rsa.pub" >> ~/.ssh/authorized_keys

echo "----------------------------------------------------------------------"
echo
echo "Now you will be sshing to helper node 192.168.58.100."
echo "You can run commands below to start the OCP IPI deployment."
echo
echo "    cd /root/${cluster_name}-installer"
echo "    ./install.sh"
echo
echo "----------------------------------------------------------------------"

ssh 192.168.58.100

