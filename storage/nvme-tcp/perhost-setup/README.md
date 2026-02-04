## PerHost Networking Config Examples

> **WIP**

- `nncp-worker-x`: NodeNetworkConfigurationPolicy for each host in seperate files, with static networking applied to the NIC on a specific VLAN. This expects that the NICs are on a trunk/tagged switchport for proper vlan encapsulation.
- `nncp-novlan-workers`: NodeNetworkConfigurationPolicy for each host in one file, with static networking defined on the NIC and mtu seet to 9000. This expects that the NICs are on a access/untagged switchport as no vlan encapsulation is being done on the host.
