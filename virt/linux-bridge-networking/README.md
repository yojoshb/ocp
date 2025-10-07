## Quick example of a bridge added to a additional NIC on worker nodes

- vm-nncp.yaml: NodeNetworkConfigurationPolicy used to set up the interface `enp6s21` as a simple bridge port `vmbr0`

- vm-nad.yaml: NetworkAttachmentDefinition called `vm-net`, used to map the bridgeport `vmbr0` to the cluster


