## Example Multus Network configuration for OpenShift Data Foundation using mac-vlan

- NAD's must be in place before the storage cluster is created

- Public Net utilizes an additional dedicated network interface for client storage traffic

- Cluster Net utilizes an additional dedicated network interface for storage replication traffic

[RH Docs](https://docs.redhat.com/en/documentation/red_hat_openshift_data_foundation/4.19/html-single/planning_your_deployment/index#multus-prerequisites_rhodf) 

### Verification 
```bash
oc get storagecluster ocs-storagecluster -n openshift-storage -o=jsonpath='{.spec.network}{"\n"}'
```

```bash
oc get -n openshift-storage $(oc get pods -n openshift-storage -o name -l app=rook-ceph-osd | grep 'osd-0') -o=jsonpath='{.metadata.annotations.k8s\.v1\.cni\.cncf\.io/network-status}{"\n"}'
```