#!/bin/bash

OC="$(command -v oc)"

for node in $(${OC} get nodes -l node-role.kubernetes.io/worker -o jsonpath='{.items[*].metadata.name}'); do
  ${OC} label node ${node} cluster.ocs.openshift.io/openshift-storage=''
done
