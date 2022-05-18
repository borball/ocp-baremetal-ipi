#!/bin/bash

CLUSTER=${cluster_name}
VIRT_NIC=${network_name}

kcli create vm -i centos8stream -P start=True -P memory=8000 -P numcpus=2 -P disks=[200] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"eth0\",\"mac\":\"de:ad:be:ff:00:01\"}"] -P dualstack=true ${CLUSTER}-helper