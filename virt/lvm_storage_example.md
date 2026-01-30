### LVMs Operator Example 

- Set `lvms-vg1` to be clusterwide default `virt` storageclass, you can only have one
```bash
oc patch storageclass lvms-vg1 -p '{"metadata": {"annotations": {"storageclass.kubevirt.io/is-default-virt-class": "true"}}}'
```

- Optionally, set `lvms-vg1` to be the clusterwide default storageclass, you can only have one
```bash
oc patch storageclass lvms-vg1 -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'
```

- After the KubeVirt Operator is installed, edit the storageprofile. The LVMs operator can do block and filesystem, as well as `csi-clone` which is faster than the default `copy` strategy
```bash
oc edit storageprofiles lvms-vg1
```

```yaml
# Add to the spec, example below
spec:
  claimPropertySets:
  - accessModes:
    - ReadWriteOnce
    volumeMode: Block
  - accessModes:
    - ReadWriteOnce
    volumeMode: Filesystem
  cloneStrategy: csi-clone
```