## Storage Networking Config Examples

> **WIP**

Information will be placed here mainly for HPE-CSI NVMe/TCP setup and best practices for the **HPE Alletra Storage MP B10000**. Only one VLAN can be on a controller at a time when doing NVME/TCP multi-pathing. [Known Issues](https://github.com/hpe-storage/csi-driver/blob/master/release-notes/v3.1.0.md#known-issues)

### Network/CoreOS Prereqs 

- hostnqn/hostid will need to be configured via `MachineConfig` to generate correct NVMe Hostnqn and NVMe Hostid for NVMe/TCP kernel driver

```yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: 99-worker-nvme-gen-hostnqn-hostid
spec:
  config:
    ignition:
      version: 3.4.0
    systemd:
      units:
        - contents: |
            [Unit]
            Description=CoreOS Generate NVMe Hostnqn
            Documentation=https://bugzilla.redhat.com/show_bug.cgi?id=2049991#c2
            Before=nvmefc-boot-connection.service
            [Service]
            Type=oneshot
            ExecStart=/usr/bin/sh -c 'nvme gen-hostnqn > /etc/nvme/hostnqn'
            RemainAfterExit=yes
            [Install]
            WantedBy=multi-user.target
          enabled: true
          name: nvme-gen-hostnqn.service
        - contents: |
            [Unit]
            Description=CoreOS Generate NVMe Hostid
            Documentation=https://bugzilla.redhat.com/show_bug.cgi?id=2049991#c2
            Before=nvmefc-boot-connection.service
            [Service]
            Type=oneshot
            ExecStart=/usr/bin/sh -c 'dmidecode -s system-uuid > /etc/nvme/hostid'
            RemainAfterExit=yes
            [Install]
            WantedBy=multi-user.target
          enabled: true
          name: nvme-gen-hostid.service
```

- If using dedicated network interfaces, they will need to be configured using `NodeNetworkConfigurationPolicy` via NMState Operator. A NNCP for one targeted worker node below, using eno2 and eno3, applying static IP addresses to the node NICs on the storage VLANs.

```yaml
apiVersion: nmstate.io/v1
kind: NodeNetworkConfigurationPolicy
metadata:
  name: worker1-storage-network-policy
spec:
  nodeSelector: # Use node selectors to target nodes with specific IP addresses
    kubernetes.io/hostname: worker1.cluster.example.com # Here we tell the nncp which node to apply it to
  desiredState:
    interfaces:
    - name: eno2 # Whatever your interface is called
      description: Storage network port using eno2 - 172.16.101.1 # You can give it a good description to logically map everything
      type: ethernet
      state: up
      mtu: 9000 # Optional: Set the MTU on the iface
      ipv4:
        enabled: true
        dhcp: false
        address:
          - ip: 172.16.101.1 # The IP address of this node on the vlan
            prefix-length: 24
      ipv6:
        enabled: false
    - name: eno3 # Whatever your interface is called
      description: Storage network port using eno3 - 172.16.102.1 # You can give it a good description to logically map everything
      type: ethernet
      state: up
      mtu: 9000 # Optional: Set the MTU on the iface
      ipv4:
        enabled: true
        dhcp: false
        address:
          - ip: 172.16.102.1 # The IP address of this node on the vlan
            prefix-length: 24
      ipv6:
        enabled: false
```

### CSI Install

- Reference https://scod.hpedev.io/welcome/index.html

1. Create the namespace: https://scod.hpedev.io/csi_driver/partners/redhat_openshift/index.html#prerequisites

```bash
oc new-project hpe-storage --display-name="HPE CSI for OpenShift"
```

2. Apply SCC directly by url, or download then apply

```bash
oc apply -f https://scod.hpedev.io/csi_driver/partners/redhat_openshift/examples/scc/hpe-csi-scc.yaml
```
```bash
wget https://scod.hpedev.io/csi_driver/partners/redhat_openshift/examples/scc/hpe-csi-scc.yaml
oc apply -f hpe-csi-scc.yaml
```

3. Install via Operator or Helm

- [Operator](https://scod.hpedev.io/csi_driver/partners/redhat_openshift/index.html#overview): The Operator is the recommended approach
- [Helm](https://artifacthub.io/packages/helm/hpe-storage/hpe-csi-driver): Helm is *unsupported* on OpenShift but HPE will support installation and configuration. Only the Helm chart supports the beta-releases, which is unsupported by both HPE and Red Hat for production.

4. Create a yaml file to configure backend Secrets: https://scod.hpedev.io/csi_driver/using.html

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: hpe-backend
  namespace: hpe-storage
stringData:
  serviceName: alletrastoragemp-csp-svc
  servicePort: "8080"
  backend: 192.168.1.110:443
  username: 3paradm
  password: 3pardata
```
```bash
oc apply -f <your_hpe_backend_secret.yaml>
```

5. Create storageclass (MP B10000 specific): https://scod.hpedev.io/csi_driver/container_storage_provider/hpe_alletra_storage_mp_b10000/index.html#storageclass_parameters
    - Base Storage Class Parameters: https://scod.hpedev.io/csi_driver/container_storage_provider/hpe_alletra_storage_mp_b10000_file_service/index.html
    - Container Storage Providers: https://scod.hpedev.io/csi_driver/container_storage_provider/index.html

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    # There can only be one default StorageClass per cluster
    storageclass.kubernetes.io/is-default-class: "true"
  name: hpe-standard-nvme
parameters:
  csi.storage.k8s.io/controller-expand-secret-name: hpe-backend
  csi.storage.k8s.io/controller-expand-secret-namespace: hpe-storage
  csi.storage.k8s.io/controller-publish-secret-name: hpe-backend
  csi.storage.k8s.io/controller-publish-secret-namespace: hpe-storage
  csi.storage.k8s.io/node-publish-secret-name: hpe-backend
  csi.storage.k8s.io/node-publish-secret-namespace: hpe-storage
  csi.storage.k8s.io/node-stage-secret-name: hpe-backend
  csi.storage.k8s.io/node-stage-secret-namespace: hpe-storage
  csi.storage.k8s.io/provisioner-secret-name: hpe-backend
  csi.storage.k8s.io/provisioner-secret-namespace: hpe-storage
  csi.storage.k8s.io/fstype: xfs
  accessProtocol: nvmetcp
  description: Volume created by the HPE CSI Driver for Kubernetes
  cpg: SSD_r6 # Not Required
  snapCpg: SSD_r6 # Not Required
  hostSeesVLUN: "true"
  provisioningType: tpvv
provisioner: csi.hpe.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
```
```bash
oc apply -f <your_hpe_backend_storageclass.yaml>
```

6. To configure File Services: https://scod.hpedev.io/csi_driver/container_storage_provider/hpe_alletra_storage_mp_b10000_file_service/index.html

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: hpe-standard-rwx
parameters:
  csi.storage.k8s.io/controller-expand-secret-name: hpe-backend
  csi.storage.k8s.io/controller-expand-secret-namespace: hpe-storage
  csi.storage.k8s.io/controller-publish-secret-name: hpe-backend
  csi.storage.k8s.io/controller-publish-secret-namespace: hpe-storage
  csi.storage.k8s.io/node-publish-secret-name: hpe-backend
  csi.storage.k8s.io/node-publish-secret-namespace: hpe-storage
  csi.storage.k8s.io/node-stage-secret-name: hpe-backend
  csi.storage.k8s.io/node-stage-secret-namespace: hpe-storage
  csi.storage.k8s.io/provisioner-secret-name: hpe-backend
  csi.storage.k8s.io/provisioner-secret-namespace: hpe-storage
  csi.storage.k8s.io/fstype: ext4 # EXT4 Recommended
  accessProtocol: nvmetcp
  description: NFS-backed shared volume created by the HPE CSI Driver
  hostSeesVLUN: "true"
  provisioningType: tpvv
  nfsResources: "true"
provisioner: csi.hpe.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
```
