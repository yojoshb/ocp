OpenShift comes with NFS capabilities out of the box, for using a NFS mountpoint for persistent storage. However, this cannot dynamically create persistent volume's dynamically. The `nfs-subdir-external-provisioner` allows this behavior and is generally muh easier to utilize. 

Make sure your NFS server is accessible from your Kubernetes cluster and get the information you need to connect to it. At a minimum you will need its hostname.

https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner

## Basic Install

1. Clone the repo and cd into it
```bash
git clone https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner.git
cd nfs-subdir-external-provisioner
```

2. Create a new project/namespace for the provisioner
```bash
oc new-project nfs-client-provisioner
```

3. Create a backup of the original files, as these files need to be edited manually
```bash
cp deploy/rbac.yaml deploy/rbac.yaml.original
cp deploy/deployment.yaml deploy/deployment.yaml.original
```

4. Replace the default namespace to nfs-client-provisioner in both files
```bash
sed -i'' "s/namespace:.*/namespace: nfs-client-provisioner/g" ./deploy/rbac.yaml ./deploy/deployment.yaml
```

5. Create the rbac for the service account
```bash
oc create -f deploy/rbac.yaml
```

6. Add the `hostmount-anyuid` scc to the nfs-client-provisioner service account
```bash
oc adm policy add-scc-to-user hostmount-anyuid system:serviceaccount:nfs-client-provisioner:nfs-client-provisioner
```

7. Edit deployment to your liking `vim deploy/deployment.yaml`, then create the deployment
```bash
oc create -f deploy/deployment.yaml -n nfs-client-provisioner
```

8. Edit class to your liking `vim deploy/class.yaml`, then create the storage class
```bash
oc create -f deploy/class.yaml
```

## Disconnected Install
Pretty much the same, you'll just need to bring the resources over to your disconnected env.

1. Clone the repo and tar it up
```bash
git clone https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner.git
tar -cvf nfs-subdir-external-provisioner.tar nfs-subdir-external-provisioner
```

2. Mirror the image
- If using oc mirror, add it to your imageset-config under additionalImages:
```yaml
kind: ImageSetConfiguration
apiVersion: mirror.openshift.io/v1alpha2
mirror:
  ...
  additionalImages:
  - name: registry.k8s.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2
```

- Or mirror manually
```bash
podman pull registry.k8s.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2
podman save -o nfs-subdir-external-provisioner.tar registry.k8s.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2
```

3. Transfer the image.tar/mirror_000001.tar and git repo to disconnected env

4. If you used oc mirror, just perform the regular disk-to-mirror workflow. If you mirrored manually load and push the image to your registry that OpenShift can access. 
```bash
podman load -i nfs-subdir-external-provisioner.tar
podman push registry.k8s.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2 registry.example.com/nfs-subdir-external-provisioner:v4.0.2
```

5. Unpack the git repo and edit the `deployment` to reference the image you have in your registry. Configuration/deployment is the same as the basic install.