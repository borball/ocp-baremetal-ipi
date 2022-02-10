## OpenShift IPI Deployment on BareMetal

This repo is designed to deploy a Red Hat OpenShift cluster with IPI method on a BareMetal server. 

<img src="ocp-ipi.svg" width=90% >

- Host: RHEL8, 32 cores, 128G RAM
- BareMetal Network: 192.168.200.0/24
- Helper VM: 192.168.200.100, CentOS8
- Bootstrap Node: Dynamic IP
- Control Plane:
  - openshift-master-0: 192.168.200.105
  - openshift-master-0: 192.168.200.106
  - openshift-master-0: 192.168.200.107
- Ingress VIP: 192.168.200.102
- Base Domain: virtual.cluster.lab
- Cluster Name: ocp4

### Quick Start

```shell

git clone https://github.com/borball/ocp-baremetal-ipi.git
cd ocp-baremetal-ipi

#Update config.cfg before running setup.sh, especially for the dns server.

./setup.sh
```

Once all steps completed successfully, all files in folder helper_node will be rsync to the created helper VM, you will be sshing to the helper node automatically.

```shell
cd ocp4-installer
# It may take more than 1 hour to finish,
# you may want to run it in the backend. i.g. nohup ./install.sh &
./install.sh
```

After around 1 hour an OpenShift cluster will be installed:

```
# oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.8.5     True        False         9h      Cluster version is 4.8.5

# oc get nodes
NAME                 STATUS   ROLES    AGE   VERSION
openshift-master-0   Ready    master   11h   v1.21.1+9807387
openshift-master-1   Ready    master   11h   v1.21.1+9807387
openshift-master-2   Ready    master   11h   v1.21.1+9807387
```

### Cleanup

On the host:
```shell
./clean.sh
```

All the VMs and network will be deleted so nothing left on the host.

### Other Deployment

- [OCP disconnected IPv4 with 3 control plane and 3 worker nodes](https://github.com/borball/ocp-baremetal-ipi/tree/disconnected)
- [OCP disconnected IPv4 with 3 control plane](https://github.com/borball/ocp-baremetal-ipi/tree/disconnected-3)