## Machine Config examples for NVMe/TCP

> **WIP**

Information will be placed here mainly for NVMe/TCP setup and best practices. By default CoreOS nodes will not have sufficient hostnqn's & hostid's generated as they get cloned during install. You can fix it by supplying proper machine configs to the nodes. Note: many CSI's drivers will include code to accomplish this task for you. Only apply these if your CSI does not do it for you.  

- `99-worker-nvme-discovery.bu`: Butane file to generate a nvme discovery file
- `99-worker-nvme-gen-hostnqn-hostid.yaml`: A simple MachineConfig to generate correct NVMe Hostnqn and NVMe Hostid for NVMe/TCP kernel driver

#### Reference links
https://github.com/openshift/machine-config-operator/blob/main/docs/custom-pools.md

https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/machine_configuration/machine-config-index

https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/managing_storage_devices/configuring-nvme-over-fabrics-using-nvme-tcp_managing-storage-devices

https://access.redhat.com/solutions/7073579

