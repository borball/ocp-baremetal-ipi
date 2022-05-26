#!/bin/bash

CLUSTER=${cluster_name}
VIRT_NIC=${network_name}

kcli create vm -P start=False -P memory=32000 -P numcpus=16 -P disks=[100,200] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"eth0\",\"mac\":\"de:ad:be:ff:00:05\"}"] ${CLUSTER}-master0
kcli create vm -P start=False -P memory=32000 -P numcpus=16 -P disks=[100,200] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"eth0\",\"mac\":\"de:ad:be:ff:00:06\"}"] ${CLUSTER}-master1
kcli create vm -P start=False -P memory=32000 -P numcpus=16 -P disks=[100,200] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"eth0\",\"mac\":\"de:ad:be:ff:00:07\"}"] ${CLUSTER}-master2

