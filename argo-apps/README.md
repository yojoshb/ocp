## Red Hat OpenShift GitOps Example Apps

ArgoCD repository for various applications

1. Install the OpenShift GitOps Operator from OperatorHub
2. If you want to give ArgoCD access to all namespaces on the cluster, add the cluster-admin role to the application controller
```bash
oc adm policy add-cluster-role-to-user cluster-admin -z openshift-gitops-argocd-application-controller -n openshift-gitops
```
3. Set up repository in ArgoCD using SSH or HTTPS
4. Create applications from the repository created
