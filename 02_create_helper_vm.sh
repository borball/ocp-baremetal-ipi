#!/bin/bash

CLUSTER=${cluster_name}
VIRT_NIC=${network_name}

kcli create vm -i centos8stream -P start=True -P memory=8000 -P numcpus=2 -P disks=[300] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"eth0\",\"mac\":\"de:ad:be:ff:00:00\",\"ip\":\"${helper_node_ip}\",\"mask\":\"${network_mask}\",\"dns\":\"${dns_server}\",\"gateway\":\"${network_gateway}\"}"] ${CLUSTER}-helper