#!/bin/bash

if [[ $(kcli list networks | grep -c ${network_name}) != 1 ]]
then
  kcli create network -c "${network_subnet}" --domain ${network_domain} --nodhcp ${network_name}
fi
