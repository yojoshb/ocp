## PerPod Addressing Config Examples

> **WIP**

- `nncp-perpod-netapp.yaml`: Simple NodeNetworkConfigurationPolicy for VLAN tagging on a secondary network interface for a dedicated storage network
- `nad-netapp-x.yaml`: NetworkAttachmentDefination's for the node NIC to apply static networking to connect to the storage pods (This is the alternative, creating multiple NADs with static IPs, then patching the necessary storage pods with static addresses)
