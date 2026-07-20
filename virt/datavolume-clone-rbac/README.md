## Common Role Bindings 

### DataVolumes clone between namespaces
You may want to put your ISO's or bootable 'golden images' in a separate namespace for organizational purposes, or you want to clone existing VM's to a different namespace. By default the ContainerDataImporter (CDI) will not have sufficient access under the `default` service account within the namespace to clone data volumes between namespaces. Modify and use the provided yaml to enable the ability to do so.

- For this example, you have created a namespace called `vm-iso` and have uploaded ISO's to this namespace as DataVolumes
- You have created a namespace just for virtual machines called `virtual-machines`
- Create the appropriate RBAC Role and RoleBinding to allow DataVolumes to be cloned from the `vm-iso` to the `virtual-machines` namespace
- Now that you have a `ClusterRole` that has permissions, create any additional `RoleBinding's` to clone resources between namespaces