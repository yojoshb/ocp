## Erase disk that was an ODF/CEPH OSD.
Link: https://access.redhat.com/solutions/7115651

- There are 2 methods to clean/wipe disks to be used for ODF OSDs.
    - Method 1 is intended for OCP / ODF clusters running 4.16 or higher.
    - Method 2 is intended for OCP / ODF clusters running 4.15 or lower.
    - Method 2 is also intended as a fall back if method 1 fails.

### Method 1

1. Identify the image running rook-ceph-operator
```bash
# Syntax 
oc get deploy -n openshift-storage rook-ceph-operator -o jsonpath='{.spec.template.spec.containers[].image}'

# Example
oc get deploy -n openshift-storage rook-ceph-operator -o jsonpath='{.spec.template.spec.containers[].image}' registry.redhat.io/odf4/rook-ceph-rhel9-operator@sha256:60623084100a785f7eaf4bd3a4f87de4982daa37e30849bdb0b8304d3d1b7cd5
```

2. Clean the device on the node, using podman to run the operators image
```bash
#Syntax
/usr/bin/podman run --authfile /var/lib/kubelet/config.json --rm -ti --privileged --device <device-path> --entrypoint ceph-bluestore-tool <rook-ceph-operator-image> zap-device --dev <device-path> --yes-i-really-really-mean-it

# Examples
/usr/bin/podman run --authfile /var/lib/kubelet/config.json --rm -ti --privileged --device /dev/sdc --entrypoint ceph-bluestore-tool registry.redhat.io/odf4/rook-ceph-rhel9-operator@sha256:60623084100a785f7eaf4bd3a4f87de4982daa37e30849bdb0b8304d3d1b7cd5 zap-device --dev /dev/sdc --yes-i-really-really-mean-it

/usr/bin/podman run --authfile /var/lib/kubelet/config.json --rm -ti --privileged --device /dev/nvme1n1 --entrypoint ceph-bluestore-tool registry.redhat.io/odf4/rook-ceph-rhel9-operator@sha256:60623084100a785f7eaf4bd3a4f87de4982daa37e30849bdb0b8304d3d1b7cd5 zap-device --dev /dev/nvme1n1 --yes-i-really-really-mean-it
```

### Method 2
1. Perform this on the node
```bash
DISK="/dev/sdX"
DISK="/dev/nvme1n1"

# Wipe the partition table off the disk to a fresh, usable state.
wipefs -fa $DISK

# Wipe certain areas of the disk to remove Ceph Metadata which may be present.
for gb in 0 1 10 100 1000; do dd if=/dev/zero of="$DISK" bs=1K count=200 oflag=direct,dsync seek=$((gb * 1024**2)); done

# This might not be supported on all devices.
blkdiscard $DISK
```

### Notes
Starting with ODF 4.20, you can add the following spec to the `StorageCluster CR` to ensure clean redeployment. This configuration wipes any existing Ceph BlueStore metadata from OSD disks before they are reused, preventing conflicts from previous deployments.
```yaml
spec:
  managedResources:
    cephCluster: 
      cleanupPolicy:
        wipeDevicesFromOtherClusters: true 
```