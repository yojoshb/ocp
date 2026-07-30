## ODF Troubleshooting 
This README will contain various troubleshooting items that may occur in ODF deployment/usage

- Enable the `rook-ceph-tools` pod to interact with the underlying storage system. A new pod will spin up in the `openshift-storage` namespace
```bash
oc patch storagecluster ocs-storagecluster -n openshift-storage --type json --patch '[{ "op": "replace", "path": "/spec/enableCephTools", "value": true }]'
```

### Stale Subvolumes
If a PVC is deleted forcefully or somehow you have lingering resources that exist in the Ceph filesystem but not in the cluster, you will get alerts letting you know there are stale volumes

1. Enter the `rook-ceph-tools-xxx` pod through the webconsole or commandline
```bash
oc exec -it po/rook-ceph-tools-5b5997f94d-xsql6 -n openshift-storage -- /bin/bash
```

2. List the filesystem to get the name of it
```bash
ceph fs ls
```
```
name: ocs-storagecluster-cephfilesystem, metadata pool: ocs-storagecluster-cephfilesystem-metadata, data pools: [ocs-storagecluster-cephfilesystem-data0 ]
```

3. List the subvolume groups within the filesystem
```bash
ceph fs subvolumegroup ls ocs-storagecluster-cephfilesystem
```
```json
[
    {
        "name": "csi"
    }
]
```

4. Now we can list the actual subvolumes within the group
```bash
ceph fs subvolume ls ocs-storagecluster-cephfilesystem --group_name csi
```
```json
[
    {
        "name": "csi-vol-2bdd73a7-2c2a-40a8-9846-d9bc131673b1"
    },
    {
        "name": "csi-vol-bd600228-4cb4-49bd-ada4-df02a1920e7a"
    },
    {
        "name": "csi-vol-dbef4de0-8ee7-49db-a71b-a33e08aa9179"
    },
    {
        "name": "csi-vol-86122de2-3300-46b6-a236-00fd1ddd1c62"
    }
]
```

5. Grab another terminal to interact with the cluster. We need to find the subvolumes that match to the inderlying PVC's
```bash
oc get pv -o custom-columns=NAME:.metadata.name,DRIVER:.spec.csi.driver,SUBVOLUME:.spec.csi.volumeHandle | grep cephfs
```
```bash
                                                                                                                                # UUID's 
pvc-6afeedee-9f5c-4d11-9c52-295c892311d9   openshift-storage.cephfs.csi.ceph.com   0001-0011-openshift-storage-0000000000000001-2bdd73a7-2c2a-40a8-9846-d9bc131673b1
pvc-951b2ed4-b0ae-4dec-bb1f-9c52674fa387   openshift-storage.cephfs.csi.ceph.com   0001-0011-openshift-storage-0000000000000001-86122de2-3300-46b6-a236-00fd1ddd1c62
pvc-fbfe40c0-78db-4abf-98f0-27646628a32d   openshift-storage.cephfs.csi.ceph.com   0001-0011-openshift-storage-0000000000000001-bd600228-4cb4-49bd-ada4-df02a1920e7a
```

6. Compare the UUID's to determine what PVC doesn't map to the `volumeHandle`. In this case, there is no PVC mapping to `csi-vol-dbef4de0-8ee7-49db-a71b-a33e08aa9179`

7. Go back to the `rook-ceph-tools` pod and delete the stale subvolume
```bash
ceph fs subvolume rm ocs-storagecluster-cephfilesystem csi-vol-dbef4de0-8ee7-49db-a71b-a33e08aa9179 --group_name csi
```

8. The alert will clear after a few minutes once Prometheus scrapes the `ceph-mgr` endpoint again