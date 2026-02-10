## PerHost Networking Config Examples

> **WIP**

- `nncp-vlan-workers`: NodeNetworkConfigurationPolicy for each host in one file, with static networking applied to the NIC on a specific VLAN. This expects that the NICs are on a trunk/tagged switchport for proper vlan encapsulation.
- `nncp-novlan-workers`: NodeNetworkConfigurationPolicy for each host in one file, with static networking defined on the NIC and mtu set to 9000. This expects that the NICs are on a access/untagged switchport as no vlan encapsulation is being done on the host.

### Remove nncp's procedure

1. Set the state's to `absent` and reapply the configs

```yaml
apiVersion: nmstate.io/v1
kind: NodeNetworkConfigurationPolicy
metadata:
  name: worker1-storage-network-policy
spec:
  nodeSelector:
    kubernetes.io/hostname: worker1.cluster.example.com
  desiredState:
    interfaces:
    - name: eno2
      type: ethernet
      state: absent # Set to absent
      mtu: 9000
      ipv4:
        enabled: false
      ipv6:
        enabled: false
    - name: eno2.18
      description: VLAN 18 using eno2 - 192.168.18.1
      type: vlan
      state: absent # Set to absent
      mtu: 9000
      ipv4:
        enabled: true
        dhcp: false
        address:
          - ip: 192.168.18.1 
            prefix-length: 24
      ipv6:
        enabled: false
      vlan:
        base-iface: eno2 # Whatever your interface is called
        id: 18 # The vlan tag to assign
```

2. Delete the nncp from the cluster
```bash
oc delete nncp worker1-storage-network-policy
```