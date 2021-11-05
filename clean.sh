#!/bin/bash

BASEDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source ${BASEDIR}/config.cfg

read -p "Are you sure? [y/n]: " DELETE

if [[ ${DELETE} == "y" ]]
then
  kcli delete vm ${cluster_name}-master0 ${cluster_name}-master1 ${cluster_name}-master2 ${cluster_name}-worker0 ${cluster_name}-worker1 ${cluster_name}-worker2 -y
  BOOTSTRAP=$(kcli list vm | grep "${cluster_name}-.*bootstrap" | awk -F "|" '{print $2}' | tr -d " " )
  if [[ ${BOOTSTRAP} != "" ]]
  then
    kcli delete vm ${BOOTSTRAP} -y
  fi
fi

kcli delete vm ${cluster_name}-helper -y

kcli delete network ${network_name} -y



