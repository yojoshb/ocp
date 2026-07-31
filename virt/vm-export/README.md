## virtctl vmexport
You can use `virtctl` to export your qcow2 images from the cluster among many other things

1. Get the name of the PVC that contains the virtual machine
```bash
oc get pvc
NAME                                      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                                 VOLUMEATTRIBUTESCLASS   AGE
persistent-state-for-windows-11-2-wz72n   Bound    pvc-fbfe40c0-78db-4abf-98f0-27646628a32d   12Mi       RWX            ocs-storagecluster-cephfs                    <unset>                 7d21h
windows-11-2-volume-blank                 Bound    pvc-49d58048-320e-4eda-9fef-e56ea3dbc23b   64Gi       RWX            ocs-storagecluster-ceph-rbd-virtualization   <unset>                 7d21h
windows11-25h2-iso-amd64                  Bound    pvc-ae188dbe-1101-4cff-90d8-81b82f84e2fa   30Gi       RWX            ocs-storagecluster-ceph-rbd-virtualization   <unset>                 7d21h
```

2. Download the selected virtual machine to your local machine
```bash
virtctl vmexport download windows-11-export --pvc=windows-11-2-volume-blank --output=windows11.qcow2
```

3. Check on the status of the export in case of it not starting
```bash
oc get virtualmachineexports.export.kubevirt.io windows-11-export -oyaml
```