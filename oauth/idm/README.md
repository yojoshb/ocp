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
