## Red Hat Offline Knowledge Portal on OpenShift
https://developers.redhat.com/articles/2025/10/03/how-deploy-offline-knowledge-portal-openshift

https://docs.redhat.com/en/documentation/red_hat_offline_knowledge_portal/1/install-make_red_hat_expert_knowledge_available_in_offline_environments

### 1. Login and download the image
Requires a Satellite Subscription. Also need to generate a Access Key: https://access.redhat.com/offline/access

```bash
podman login registry.redhat.io 
```

```bash
podman pull registry.redhat.io/offline-knowledge-portal/rhokp-rhel9:latest 
```

```bash
podman save --format oci-archive -o rhokp.tar registry.redhat.io/offline-knowledge-portal/rhokp-rhel9:latest
```

- Make sure to save and bring your key with you: `echo "my-access-key-87wgerkhsdbf9w867yfg" > rhokp-key.txt`

### 2. Move the image to the high-side and load it
```bash
podman load -i rhokp.tar
```

```bash
podman push registry.redhat.io/offline-knowledge-portal/rhokp-rhel9:latest registry.example.com/offline-knowledge-portal/rhokp-rhel9:latest
```
- Might have to add a `--remove-signatures` to your podman command if signatures aren't mirrored. Pretty sure if you omit the `--format` on the podman save signatures will stay in tact.. need to test, or just use skopeo  

### 3. Deploy on the cluster
```bash
oc new-project rhokp
```

- Create a secret that can store your access key
```bash
oc create secret generic access-key --from-literal=access-key=<YOUR_ACCESS_KEY> -n rhokp
```

- Create the Deployment, service, and route. See example `rhokop.yaml`, customize to your hearts content
```bash
oc create -f rhokp.yaml
```

- It'll take a bit for it to spin up, the image is around 10Gb

- Get the route
```bash
oc get route -n rhokp
NAME    HOST/PORT              PATH   SERVICES   PORT   TERMINATION     WILDCARD
rhokp   docs.apps.ocp.lab.io          rhokp      8080   edge/Redirect   None
```