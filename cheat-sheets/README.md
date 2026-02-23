## Various things that my brain never recalls to completeness

- Pull container names out of pods
```bash
oc get -n openshift-monitoring pod/prometheus-k8s-0 -o json | jq .spec.containers[].name
```

- Shell into a container from a pod
```bash
oc exec -it -n openshift-monitoring po/prometheus-k8s-0 -c prometheus -- /bin/sh
```

- Check what images are bundled with operators. This is simply just reading the json out from the operator-index container
```bash
podman run --rm -it --entrypoint cat registry.redhat.io/redhat/redhat-operator-index:v4.19 /configs/kubevirt-hyperconverged/catalog.json | jq -r 'select(.name=="kubevirt-hyperconverged-operator.v4.19.9") | .relatedImages[].image' | sed 's/\s\+/\n/g'
```

- General pod status from a selected namespace
```bash
oc get pods -n openshift-monitoring \
  -o custom-columns=PodName:".metadata.name",\
ContainerName:"spec.containers[].name",\
Phase:"status.phase",\
IP:"status.podIP",\
Ports:"spec.containers[].ports[].containerPort"
```