#!/bin/bash

if [[ $(kcli list networks | grep -c ${network_name}) != 1 ]]
then
  kcli create network -c "192.168.58.14/25" -d "2620:52:0:1304::/64" --domain ${network_domain} --nodhcp ${network_name}
fi
