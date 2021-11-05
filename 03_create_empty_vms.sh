#!/bin/bash

CLUSTER=${cluster_name}
VIRT_NIC=${network_name}

kcli create vm -P start=False -P memory=16000 -P numcpus=16 -P disks=[50,100] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"ens3\",\"mac\":\"de:ad:be:ff:00:05\"}"] ${CLUSTER}-master0
kcli create vm -P start=False -P memory=16000 -P numcpus=16 -P disks=[50,100] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"ens3\",\"mac\":\"de:ad:be:ff:00:06\"}"] ${CLUSTER}-master1
kcli create vm -P start=False -P memory=16000 -P numcpus=16 -P disks=[50,100] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"ens3\",\"mac\":\"de:ad:be:ff:00:07\"}"] ${CLUSTER}-master2
kcli create vm -P start=False -P memory=8192 -P numcpus=4 -P disks=[50,100] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"ens3\",\"mac\":\"de:ad:be:ff:00:08\"}"] ${CLUSTER}-worker0
kcli create vm -P start=False -P memory=8192 -P numcpus=4 -P disks=[50,100] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"ens3\",\"mac\":\"de:ad:be:ff:00:09\"}"] ${CLUSTER}-worker1
kcli create vm -P start=False -P memory=8192 -P numcpus=4 -P disks=[50,100] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"ens3\",\"mac\":\"de:ad:be:ff:00:10\"}"] ${CLUSTER}-worker2

