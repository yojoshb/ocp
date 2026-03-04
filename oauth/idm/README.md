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
Dry run to make sure things are lining up
oc adm groups sync --sync-config=idm-ldap-sync-config.yaml

# Apply it for real
oc adm groups sync --sync-config=idm-ldap-sync-config.yaml --confirm
```

4. Map the RBAC controls to the synced groups
```bash
oc adm policy add-cluster-role-to-group cluster-admin ocp-admins
oc adm policy add-cluster-role-to-group cluster-admin ocp-users
```


### Helpful tidbits

- Perform an LDAP search
```
# Install tools
dnf install -y openldap-clients

# Look specifically for your bind account, this will give you the correct bindDN
ldapsearch -x -H ldap://idm.lab.io -s sub "(uid=ldap_bind)"
```
