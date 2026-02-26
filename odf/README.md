## Internal ODF networking example

1. Install the Kubernetes NMState Operator
2. Create the namespace that ODF will utilize
3. Configure the networking using Multus (Optional)
4. Install the Local Storage Operator
5. Install ODF, optionally use the public and cluster networks accordingly

### ocs-storagecluster-ceph-rbd default class
By default, at least in 4.19.3, the `ocs-storagecluster-ceph-rbd` storageclass will be set to default. If you try removing the annotation from the storageclass, the ocs-storagecluster will revert your changes and put it right back. 

- To remove that behavior edit the ocs-storagecluster, and set the defaultStorageClass to false under managedResources
```bash
oc edit storagecluster ocs-storagecluster -n openshift-storage
```

```yaml
spec:
  managedResources:
    cephBlockPools:
      defaultStorageClass: false # <-- Change the managed resource from true to false
```
