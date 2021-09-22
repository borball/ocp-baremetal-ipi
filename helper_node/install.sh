#!/bin/bash

export BASEDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source ${BASEDIR}/config.cfg

export BIN_PATH=${BASEDIR}/bin
export ASSETS_PATH=${BASEDIR}/assets
export CLUSTER_PATH=${BASEDIR}/${cluster_name}
export LOCAL_SECRET_JSON=${ASSETS_PATH}/pull_secret.json

${BASEDIR}/00_install_basic_tools.sh
${BASEDIR}/01_deploy_sushy_tools.sh
${BASEDIR}/02_deploy_local_registry.sh
${BASEDIR}/03_deploy_dnsmasq.sh
${BASEDIR}/04_chrony_server.sh
${BASEDIR}/05_httpd_server.sh
${BASEDIR}/06_prepare_install_config.sh
${BASEDIR}/07_mirror_ocp_releases.sh
${BASEDIR}/08_mirror_rhcos_images.sh
${BASEDIR}/09_run_installation.sh

