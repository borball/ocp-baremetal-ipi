#!/bin/bash

dnf install -y libvirt-devel gcc python3-devel net-tools podman jq ipmitool mkisofs tmux make bash-completion

export CRYPTOGRAPHY_DONT_BUILD_RUST=1
pip3 install -U pip
pip3 install python-ironicclient --ignore-installed PyYAML

