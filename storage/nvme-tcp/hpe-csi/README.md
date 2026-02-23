## Storage Networking Config Examples

> **WIP**

Information will be placed here mainly for HPE-CSI NVMe/TCP setup and best practices for the **HPE Alletra Storage MP B10000**

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
- [Operator](https://scod.hpedev.io/csi_driver/partners/redhat_openshift/index.html#overview): The Operator is the recommended approach, but currently (v3.0.2 latest) doesn't have NVMe/TCP support
- [Helm](https://artifacthub.io/packages/helm/hpe-storage/hpe-csi-driver): Helm is *unsupported*, but provides NVMe/TCP support on v3.1.0-beta. Only the Helm chart supports the beta-releases.

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
  cpg: SSD_r6
  snapCpg: SSD_r6
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