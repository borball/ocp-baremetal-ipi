#!/bin/bash

if [[ -d /opt/dnsmasq-${cluster_name} ]]
then
  echo "/opt/dnsmasq-${cluster_name} folder detected, aborting..."
  exit 1
fi

dnf install dnsmasq -y

mkdir -p /opt/dnsmasq-${cluster_name}/

HOSTNAME=$(hostname -f)

cat <<EOF > /opt/dnsmasq-${cluster_name}/dnsmasq.conf
strict-order
bind-dynamic
bogus-priv
dhcp-authoritative
# DHCP Range
dhcp-range=${dhcp_range}
dhcp-option=option:dns-server,${helper_node_ip}
dhcp-option=option:router,${network_gateway}

resolv-file=/opt/dnsmasq-${cluster_name}/upstream-resolv.conf
except-interface=lo
dhcp-lease-max=81
log-dhcp

domain=${cluster_name}.${base_domain}

# static host-records
address=/apps.${cluster_name}.${base_domain}/${ingress_vip}
host-record=api.${cluster_name}.${base_domain},${api_vip}
host-record=openshift-master-0.${cluster_name}.${base_domain},${master0_ip}
ptr-record=${master0_ptr}.in-addr.arpa.,"openshift-master-0.${cluster_name}.${base_domain}"
host-record=openshift-master-1.${cluster_name}.${base_domain},${master1_ip}
ptr-record=${master1_ptr}.in-addr.arpa.,"openshift-master-1.${cluster_name}.${base_domain}"
host-record=openshift-master-2.${cluster_name}.${base_domain},${master2_ip}
ptr-record=${master2_ptr}.in-addr.arpa.,"openshift-master-2.${cluster_name}.${base_domain}"

# DHCP Reservations
dhcp-hostsfile=/opt/dnsmasq-${cluster_name}/hosts.hostsfile
dhcp-leasefile=/opt/dnsmasq-${cluster_name}/hosts.leases

# Registry
host-record=${HOSTNAME},${helper_node_ip}

EOF

cat <<EOF > /opt/dnsmasq-${cluster_name}/hosts.hostsfile
de:ad:be:ff:00:05,openshift-master-0,${master0_ip}
de:ad:be:ff:00:06,openshift-master-1,${master1_ip}
de:ad:be:ff:00:07,openshift-master-2,${master2_ip}
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

echo "nameserver ${helper_node_ip}" >> /etc/resolv.conf

