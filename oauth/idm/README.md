## IdM LDAP OAuth config example

1. Create a bindPassword secret. The secret key must be called `bindPassword`
```bash
oc create secret generic ldap-bind-secret --from-literal=bindPassword='your_password' -n openshift-config
```

2. Edit and apply the OAuth config
```bash
oc apply -f idm-oauth-config.yaml 
```

3. Edit and apply the LDAP sync config
```bash
# Dry run to make sure things are lining up
oc adm groups sync --sync-config=idm-ldap-sync-config.yaml

# Apply it for real
oc adm groups sync --sync-config=idm-ldap-sync-config.yaml --confirm
```

4. Map the RBAC controls to the synced groups
```bash
# This gives cluster-admin to the ocp-admins group. The same permissions that kubeadmin has, a complete superuser
oc adm policy add-cluster-role-to-group cluster-admin ocp-admins

# Note: for most user groups, it's best to define these at a project level rather than a cluster level. 
# basic-user is pretty much a read only role for the entire cluster
oc adm policy add-cluster-role-to-group basic-user ocp-users
```


### Helpful tidbits

- Perform an LDAP search
```
# Install tools
dnf install -y openldap-clients

# Look specifically for your bind account, this will give you the correct bindDN
ldapsearch -x -H ldap://idm.lab.io -s sub "(uid=ldap_bind)"
```
> LDAPS will not work on systems using self signed SSL certs
- Get clusterroles
```bash
oc get clusterroles
```
```bash
# Describe them to see what they allow
oc describe clusterroles basic-user
```

https://docs.okd.io/4.19/authentication/using-rbac.html#rbac-default-projects_using-rbac

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

# In case the admin would like to modify the descheduler params
oc adm policy add-cluster-role-to-group kubedeschedulers.operator.openshift.io-v1-admin ocp-virt-admins

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