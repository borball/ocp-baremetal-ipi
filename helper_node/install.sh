#!/bin/bash

export BASEDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source ${BASEDIR}/config.cfg

${BASEDIR}/00_install_basic_tools.sh
${BASEDIR}/01_deploy_sushy_tools.sh
${BASEDIR}/02_deploy_dnsmasq.sh
${BASEDIR}/03_chrony_server.sh
${BASEDIR}/04_config_ssh_key.sh
${BASEDIR}/05_run_installation.sh

