#!/bin/bash

dnf install chrony -y

cat <<EOF > /etc/chrony.conf
server clock.corp.redhat.com iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
bindcmdaddress ::
allow 192.168.58.0/25
EOF

systemctl enable chronyd --now

