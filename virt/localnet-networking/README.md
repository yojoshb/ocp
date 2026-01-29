## Localnet Examples for VLANs and untagged traffic

https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html-single/multiple_networks/index#configuration-localnet-switched-topology_configuring-additional-network-ovnk

- The `NodeNetworkConfigurationPolicy` examples configure a single port or bonded ports, as a ovs-bridge interface and maps it to a localnet OVN network called `localnet-trunk`. 

- After the bridge is defined, create `NetworkAttachmentDefinitions` for each VLAN, or use the `nad-novlan.yaml` to connect it to a single broadcast domain.

- If using VLANs, the upstream physical switch interface must be set to trunk/tagged so the VLAN id's are encapsulated.
