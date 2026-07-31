## Kube Descheduler
This acts as Load Balancing or DRS in VMWare terms. https://docs.okd.io/latest/virt/managing_vms/advanced_vm_management/virt-enabling-descheduler-evictions.html

1. Install the Operator
2. Set a profile, recommended Profiles are currently: `KubeVirtRelieveAndMigrate` or `LongLifeCycle`. Example spec yaml provided
3. If using the KubeVirtRelieveAndMigrate, it requires `psi=1` kernel commandline argument. Example machineconfig yaml provided

- You can set limits to improve VM eviction statbility during live migration. The descheduler can limit the number of concurrent evictions per node and across the cluster by using the `evictionLimits` field. Set these limits to match the migration limits configured in the `HyperConverged` custom resource (CR).
```yaml
spec:
  evictionLimits:
    node: 2
    total: 5
```

- Set values that correspond to the migration limits in the `HyperConverged` CR:
```yaml
spec:
  virtualization:
    liveMigrationConfig:
      parallelMigrationsPerCluster: 5
      parallelOutboundMigrationsPerNode: 2
```

- You can also exclude VM's from the eviction strategy by adding an annotation
```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
spec:
  template:
    metadata:
      annotations:
        descheduler.alpha.kubernetes.io/prefer-no-eviction: "true"
```