#!/bin/bash

if [[ $(kcli list networks | grep -c ${network_name}) != 1 ]]
then
  kcli create network -c "192.168.10.0/24" --domain ${network_domain} --nodhcp ${network_name}
fi
