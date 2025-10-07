## KubeVirt bridge/localnet network example

1. Install the Kubernetes NMState Operator
2. Optionally, create a namespace that virtual machines will utilize
3. Configure Secondary Network(s) for virtual machine traffic
4. Install the OpenShift Virtulization Operator
5. Set up storage, examples of using the LVM Operator provided (install LVM Operator)
6. Set up a VM using the `NetworkAttachmentDefinitions` for linux-bridge or localnet(prefered). This configuration will put your VM's on whatever network(s) the hosts NIC is connected
