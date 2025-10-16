### Rejected ServiceMonitor resources

You might have alerts firing from Prometheus like: `Prometheus operator in openshift-user-workload-monitoring namespace rejected <number> prometheus/ServiceMonitor resources.`

- This is from Prometheus attempting to scrape metrics from a platform namespace that doesn't have monitoring configured. You can fix it by applying the monitoring label to the affected namespace.
- This normally happens when you don't check the box `Enable Operator recommended cluster monitoring on this Namespace` when installing the Operator, or an Operator was installed as a dependency and didn't recieve the label correctly (bug imo). 

> NOTE: This is only valable for platform namespaces and you cannot set this label to a custom application namespace, which is not supported.

```bash
# This occured because ODF installed the local-storage-operator as a dependency and the label did not get set correctly

# Set the label on the targeted namespace
oc label namespace openshift-local-storage openshift.io/cluster-monitoring=true
```

#### Diagnostics
```bash
# Look through the logs to see what namespace is being errored upon
oc logs prometheus-operator-xxx -n openshift-user-workload-monitoring 
```

- Check labels
```bash
# Check labels on the namespace to see if the `openshift.io/cluster-monitoring` label is set
oc get project openshift-local-storage --show-labels
```

[KCS Article](https://access.redhat.com/solutions/6706741)
