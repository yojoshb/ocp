## Adding a node to an existing cluster installed using the Agent Based Installer

https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/nodes/working-with-nodes#adding-node-iso

1. Create `nodes-config.yaml` file, example provided

2. In order for the `create` command to fetch a release image that matches the target cluster version, you must specify a valid pull secret. You can specify the pull secret either by using the `--registry-config` flag or by setting the `REGISTRY_AUTH_FILE` environment variable beforehand. 

3. Create the ISO using `oc adm`
```bash
oc adm node-image create nodes-config.yaml
```

4. Boot the ISO on the new node

5. If you don't have reverse DNS entires for the node, the check will be skipped, and you will have to manually approve the CSR's
```bash
oc get csr
NAME        AGE    SIGNERNAME                                    REQUESTOR                                                                   REQUESTEDDURATION   CONDITION
csr-xp57v   115s   kubernetes.io/kube-apiserver-client-kubelet   system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   <none>              Pending
```

```bash
oc adm certificate approve csr-xp57v
certificatesigningrequest.certificates.k8s.io/csr-xp57v approved
```

```bash
oc get csr
NAME        AGE     SIGNERNAME                                    REQUESTOR                                                                   REQUESTEDDURATION   CONDITION
csr-hcn5t   1m48s   kubernetes.io/kubelet-serving                 system:node:w4.ocp.lab.io                                                   <none>              Pending
csr-xp57v   115s    kubernetes.io/kube-apiserver-client-kubelet   system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   <none>              Approved,Issued
```

```bash
oc adm certificate approve csr-hcn5t
certificatesigningrequest.certificates.k8s.io/csr-hcn5t approved
```

6. Check and make sure the new node joined
```bash
oc get nodes
NAME            STATUS   ROLES                  AGE     VERSION
m1.ocp.lab.io   Ready    control-plane,master   135d    v1.33.6
m2.ocp.lab.io   Ready    control-plane,master   135d    v1.33.6
m3.ocp.lab.io   Ready    control-plane,master   135d    v1.33.6
w1.ocp.lab.io   Ready    worker                 135d    v1.33.6
w2.ocp.lab.io   Ready    worker                 135d    v1.33.6
w3.ocp.lab.io   Ready    worker                 135d    v1.33.6
w4.ocp.lab.io   Ready    worker                 2m44s   v1.33.6
```
