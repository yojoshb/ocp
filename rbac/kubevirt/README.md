### KubeVirt User/Admin
To scope down the RBAC to a more granular approch for Virtualization Admins and Users, there's some predefined RBAC policies you can leverage

```bash
# Global kubevirt admin. Describe the role to see all capabilites
oc adm policy add-cluster-role-to-group kubevirt.io:admin ocp-virt-admins

# Same as above but for a specific namespace
oc adm policy add-role-to-group kubevirt.io:admin ocp-virt-admins -n virtual-machines

# Check on rolebindings within a namespace
oc get rolebindings -n virtual-machines -o wide

# Monitoring view for the cluster. 
oc adm policy add-cluster-role-to-group cluster-monitoring-view ocp-virt-admins

# Migration control
oc adm policy add-cluster-role-to-group migrations.kubevirt.io:admin ocp-virt-admins

# Multi-namespace migration control
oc adm policy add-cluster-role-to-group migrations.kubevirt.io:storagemigrate-multins ocp-virt-admins

# Cluster reader for nmstate. Allows viewing nncp and overall network topology
oc adm policy add-cluster-role-to-group nmstate-cluster-reader ocp-virt-admins

# Node-reader for the entire group
oc adm policy add-cluster-role-to-group system:node-reader ocp-virt-admins

# A cluster-admin may create specific namespaces for vm's to live in. Granting admin give full permissions within the namespace
oc adm policy add-role-to-group admin ocp-virt-admins -n virtual-machines

# Either view or admin for the entire cnv namespace
oc adm policy add-role-to-group view ocp-virt-admins -n openshift-cnv
oc adm policy add-role-to-group admin ocp-virt-admins -n openshift-cnv

# Wide net read, now can view pods, namespaces, storage, etc. Does not allow viewing of secrets
oc adm policy add-cluster-role-to-group cluster-reader ocp-virt-admins

# Check your groups
oc get groups.user.openshift.io ocp-virt-admins -o yaml
```