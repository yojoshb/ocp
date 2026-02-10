## Storage Networking Config Examples

> **WIP**

Information will be placed here mainly for NVMe/TCP setup and best practices for NetApp Trident CSI integration. This will be branched out for other vendor CSI's in the future

- `99-worker-nvme-discovery.bu`: Generate discovery file, not sure if needed for Trident
- `99-worker-nvme-gen-hostnqn-hostid.yaml`: MachineConfig to generate correct NVMe Hostnqn and NVMe Hostid for NVMe/TCP kernel driver
- `perhost-setup`: (Default behavior for CSI) Networking Configs for the node NIC to apply static IPs VLAN taqgged or not, networking to host interfaces
    - `perpod-setup`: Networking Configs to map static IP NAD's to the underlying host VLAN interface, and applied per pod


#### Various docs and links to reference
https://github.com/openshift/machine-config-operator/blob/main/docs/custom-pools.md

https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/machine_configuration/machine-config-index

https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/managing_storage_devices/configuring-nvme-over-fabrics-using-nvme-tcp_managing-storage-devices

https://access.redhat.com/solutions/7073579

https://docs.netapp.com/us-en/netapp-solutions-virtualization/openshift/osv-trident-install.html#trident-configuration-for-on-prem-openshift-cluster

https://docs.netapp.com/us-en/ontap-sanhost/nvme-rhel-9x.html

https://www.cisco.com/c/en/us/td/docs/unified_computing/ucs/UCS_CVDs/flexpod_rh_ocp_bm_xseries_manual.html
