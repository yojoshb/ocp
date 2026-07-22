## OpenShift Console Banner
Edit the provided yaml file, then apply it
```bash
oc apply -f consolebanner.yaml
```

- If you want to remove it
```bash
oc delete consolennotification banner
```

## Hacky way to restrict tab's in the Console for ease of use

1. Edit or patch the `consoles.operator.openshift.io` resource. 

- For this use case, the `ocp-virt-admins` group are `cluster-readers` so they can view all namespaces, but do not have write access to namespaces where they do not have permissions. This is simply to make the console happy being able to fetch all resources to populate it from the virtualization perspective.
  - The admin (Main Overview) console page is restricted to 'full' cluster admins that can create `clusterroles`
  - The Dev view only shows up for standard users (self-provisioners) that cannot get all namespaces
  - This can be tweaked to the hearts content

```bash
oc edit consoles.operator.openshift.io cluster
```

```yaml
spec:
  customization:
    perspectives:
    - id: admin  # Admin view is locked down to only roles/users that can create clusterroles
      visibility:
        accessReview:
          required:
          - group: rbac.authorization.k8s.io
            resource: clusterroles
            verb: create
        state: AccessReview
    - id: virtualization-perspective  # Virtualization view is locked down to only roles/users that can get all namespaces
      visibility:
        accessReview:
          required:
          - resource: namespaces
            verb: get
        state: AccessReview
    - id: dev  # Dev view is locked down to only roles/users that cannot get all namespaces
      visibility:
        accessReview:
          missing:
          - resource: namespaces
            verb: get
        state: AccessReview
```

### Checking RBAC

- Viewing what ClusterRoles are tied to a group
```bash
oc get clusterrolebindings -o json | jq '.items[] | select(.subjects[]? | .kind == "Group" and .name == "ocp-virt-admins") | {name: .metadata.name, role: .roleRef.name}'
```

- Viewing what Roles are tied to a group in namespaces
```bash
oc get rolebindings -A -o json | jq '.items[] | select(.subjects[]? | .kind == "Group" and .name == "ocp-virt-admins") | {namespace: .metadata.namespace, name: .metadata.name, role: .roleRef.name}'
```

### Impersonating a user to test permissions

```bash
$ oc auth can-i create clusterroles --as=virt-admin --as-group=ocp-virt-admins -A
no
```

```bash
$ oc auth can-i get nodes --as=virt-admin --as-group=ocp-virt-admins -A
yes
```