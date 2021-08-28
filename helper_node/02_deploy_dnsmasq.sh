#!/bin/bash

if [[ -d /opt/dnsmasq-${cluster_name} ]]
then
  echo "/opt/dnsmasq-${cluster_name} folder detected, aborting..."
  exit 1
fi

dnf install dnsmasq -y

mkdir -p /opt/dnsmasq-${cluster_name}/

cat <<EOF > /opt/dnsmasq-${cluster_name}/dnsmasq.conf
strict-order
bind-dynamic
bogus-priv
dhcp-authoritative
# DHCP Range ${cluster_name}
dhcp-range=${cluster_name},192.168.10.100,192.168.10.250,24
dhcp-option=${cluster_name},option:dns-server,192.168.10.100
dhcp-option=${cluster_name},option:router,192.168.10.1

resolv-file=/opt/dnsmasq-${cluster_name}/upstream-resolv.conf
except-interface=lo
dhcp-lease-max=81
log-dhcp

domain=${cluster_name}.${base_domain},192.168.10.0/24,local

# static host-records
address=/apps.${cluster_name}.${base_domain}/192.168.10.102
host-record=api.${cluster_name}.${base_domain},192.168.10.103
host-record=openshift-master-0.${cluster_name}.${base_domain},192.168.10.105
ptr-record=105.10.168.192.in-addr.arpa.,"openshift-master-0.${cluster_name}.${base_domain}"
host-record=openshift-master-1.${cluster_name}.${base_domain},192.168.10.106
ptr-record=106.10.168.192.in-addr.arpa.,"openshift-master-1.${cluster_name}.${base_domain}"
host-record=openshift-master-2.${cluster_name}.${base_domain},192.168.10.107
ptr-record=107.10.168.192.in-addr.arpa.,"openshift-master-2.${cluster_name}.${base_domain}"
host-record=openshift-worker-0.${cluster_name}.${base_domain},192.168.10.108
ptr-record=108.10.168.192.in-addr.arpa.,"openshift-worker-0.${cluster_name}.${base_domain}"
host-record=openshift-worker-1.${cluster_name}.${base_domain},192.168.10.109
ptr-record=109.10.168.192.in-addr.arpa.,"openshift-worker-1.${cluster_name}.${base_domain}"
host-record=openshift-worker-2.${cluster_name}.${base_domain},192.168.10.110
ptr-record=110.10.168.192.in-addr.arpa.,"openshift-worker-2.${cluster_name}.${base_domain}"

# DHCP Reservations
dhcp-hostsfile=/opt/dnsmasq-${cluster_name}/hosts.hostsfile
dhcp-leasefile=/opt/dnsmasq-${cluster_name}/hosts.leases

EOF

cat <<EOF > /opt/dnsmasq-${cluster_name}/hosts.hostsfile
de:ad:be:ff:00:05,openshift-master-0,192.168.10.105
de:ad:be:ff:00:06,openshift-master-1,192.168.10.106
de:ad:be:ff:00:07,openshift-master-2,192.168.10.107
de:ad:be:ff:00:08,openshift-worker-0,192.168.10.108
de:ad:be:ff:00:09,openshift-worker-1,192.168.10.109
de:ad:be:ff:00:10,openshift-worker-2,192.168.10.110
EOF

cat <<EOF > /opt/dnsmasq-${cluster_name}/upstream-resolv.conf
nameserver ${dns_server}
EOF


cat <<EOF > /etc/systemd/system/dnsmasq-${cluster_name}.service
[Unit]
Description=DNS server for Openshift 4 Virt clusters.
After=network.target
[Service]
User=root
Group=root
ExecStart=/usr/sbin/dnsmasq -k --conf-file=/opt/dnsmasq-${cluster_name}/dnsmasq.conf
[Install]
WantedBy=multi-user.target
EOF

touch /opt/dnsmasq-${cluster_name}/hosts.leases
semanage fcontext -a -t dnsmasq_lease_t /opt/dnsmasq-${cluster_name}/hosts.leases
restorecon -v /opt/dnsmasq-${cluster_name}/hosts.leases

systemctl daemon-reload

systemctl enable dnsmasq-${cluster_name} --now
