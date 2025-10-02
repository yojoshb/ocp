## Advanced Cluster Management: Disconnected

https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.14/html-single/clusters/index#cluster_mce_overview

Quick resources for setting up ACM and configuring the MultiClusterEngine to be able to build a semi bare-metal SNO cluster on demand in a disconnected environment. A HTTP server is required, this can be on the Hub cluster or somewhere in the environment that the Hub cluster can reach.

> Semi bare-metal meaning; this example won't go over adding BMH credentials. It will be a simple agent-ISO install that will run on bare-metal or a VM. If you have actual bare-metal machines with a BMC, the appropriate docs will be linked for those resources. 

1. Make sure the operators are mirrored correctly and installed, and the RHCOS images are pulled over to the disconnected network.

- Example ACM ImageSetConfig for oc-mirror v2
```yaml
---
kind: ImageSetConfiguration
apiVersion: mirror.openshift.io/v2alpha1

mirror:
  operators:
  - catalog: registry.redhat.io/redhat/redhat-operator-index:v4.19
    packages:

    # Advanced Cluster Management for Kuberenetes
    - name: advanced-cluster-management
      channels:
      - name: release-2.14
    - name: multicluster-engine
      channels:
      - name: stable-2.9
```

- On your connected machine, download the required Red Hat CoreOS images. Try to match the RHCOS version with the version of OpenShift set out to deploy. If you want to install via PXE or something else, you may need to provide additional images.
```bash
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.19/latest/rhcos-4.19.10-x86_64-live-iso.x86_64.iso
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.19/latest/rhcos-4.19.10-x86_64-live-rootfs.x86_64.img
```

2. On the Hub cluster (the cluster which ACM will be installed to), make sure to have a `configMap` in the `openshift-config` namespace that contains the CA of the registry where the OpenShift release images are stored.

- Create a configMap, in this case the release images are located at `registry.lab.io:8443`. These definitions are used for other ImageStreams, the OpenShift Update Service, and a couple of other places such as ACM. It may even be the same registry that the current cluster gets it's images from.
```yaml
# Root CA definitions for use by the config/Image CR
# Each image registry URL should have a corresponding entry in this ConfigMap
# with the registry URL as the key and the CA certificate as the value.
# If there is a port for the registry, use two dots to separate the registry hostname and the port.
# For example, if the registry URL is registry.example.com:5000, the key should be registry.example.com..5000
# The updateservice-registry entry is used for the OpenShift Update Service
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: image-ca-bundle
  namespace: openshift-config
data:
  # updateservice-registry is for the registry hosting OSUS Releases
  updateservice-registry: |
    -----BEGIN CERTIFICATE-----
    MIIH0DCCBbigAwIBAgIUV...
    -----END CERTIFICATE-----
  registry.lab.io..8443: |
    -----BEGIN CERTIFICATE-----
    MIIH0DCCBbigAwIBAgIUV...
    -----END CERTIFICATE-----
```

```bash
oc apply -f image-ca-bundle.yaml
```

3. Once the data has been pulled over and mirrored install the operator, default values are fine.
  - https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.14/html/install/installing#install-on-disconnected-networks

4. Place the RHCOS images on a HTTP server. This example will be a simple Apache webserver running on the host `registry.lab.io` in the disconnected network.

- The images are at:
```
# Live ISO
http://registry.lab.io/files/rhcos/4.19/rhcos-live-iso.x86_64.iso

# Rootfs
http://registry.lab.io/files/rhcos/4.19/rhcos-live-rootfs.x86_64.img"
```

5. At this point ACM is ready to use for cluster management, but MCE (MultiClusterEngine) still needs some additional configuration to be able to create a cluster. Procede to the [multi-cluster-engine directory](./multi-cluster-engine) 