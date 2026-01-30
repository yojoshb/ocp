## Installing OpenShift Data Foundations from CLI
Link: https://access.redhat.com/articles/5692201
Other handy read: https://github.com/johnsimcall/openshift-notes/blob/main/odf-with-hdd-and-nvme-pools.md

> Do not blindly apply these resources, customize them to fit your env

### Install the Local Storage Operator
1. Create openshift-local-storage namespace, lso operator group, and subscription: `oc apply -f lso-1-opinstall.yaml`
2. Label nodes: `lso-4-nodelabel.sh` to label all worker nodes, or `oc label node <node.example.com> cluster.ocs.openshift.io/openshift-storage=''` manually
3. Create LocalVolumeDiscovery job to find useable disks: `oc apply -f lso-5-discovery.yaml`
    - Check on resources: `oc get localvolumediscoveries -n openshift-local-storage` & `oc get localvolumediscoveryresults -n openshift-local-storage`
4. Create LocalVolumeSet: Modify this resource for your cluster `oc apply -f lso-6-volumeset.yaml`
    - Check for diskmaker: `oc get pods -n openshift-local-storage | grep "diskmaker-manager"`
    - Check for PV creation: `oc get pv -n openshift-local-storage`

### Install the ODF Operator
1. Create ODF namespace openshift-storage, subscribe to ocs-operator and odf-operator: `oc apply -f odf-1-opinstall.yaml`
2. Create the storage cluster: Modify this resource for your cluster `oc apply -f odf-4-createcluster.yaml`
    - Verify pods are up and running: `oc get pods -n openshift-storage`
    - List CSV to see status: `oc get csv -n openshift-storage`

### Test PVC creation
```bash
cat <<EOF | oc apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rbd-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: ocs-storagecluster-ceph-rbd
EOF
```

```bash
cat <<EOF | oc apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cephfs-pvc
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: ocs-storagecluster-cephfs
EOF
```

- Validate PVC creation
```bash
oc get pvc | grep rbd-pvc
oc get pvc | grep cephfs-pvc
```