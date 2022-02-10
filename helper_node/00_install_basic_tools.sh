#!/bin/bash

sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*

dnf install -y libvirt-devel gcc python3-devel net-tools podman jq ipmitool mkisofs tmux make bash-completion bind-utils

export CRYPTOGRAPHY_DONT_BUILD_RUST=1
pip3 install -U pip
pip3 install python-ironicclient --ignore-installed PyYAML

echo "export KUBECONFIG=/root/${cluster_name}-installer/${cluster_name}/auth/kubeconfig" >> ~/.bash_profile

cp ${BIN_PATH}/oc /usr/local/bin/

source ~/.bash_profile
