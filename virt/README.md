## KubeVirt bridge network example

1. Install the Kubernetes NMState Operator
2. Create the namespace that virtual machines will utilize
3. Configure the networking
4. Install the OpenShift Virtulization Operator
5. Set up storage, examples of using the LVM Operator provided (install LVM Operator)
6. Set up a VM using the `vm-net` bridge interface. This configuration will put your VM's on whatever network the hosts NIC is connected to
