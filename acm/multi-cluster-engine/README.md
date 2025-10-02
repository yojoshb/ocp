## Multi Cluster Engine

https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.14/html-single/clusters/index#cim-intro

- Edit the configs accordingly and apply them

```bash
# Create the configmap for the assisted-service. This will set default env values for the AgentServiceConfig
oc apply -f assisted-service-cm.yaml

# Create the configmap for the mirror registry. This will set the agent-iso /etc/containers/registries.conf to use your mirror registry
oc apply -f mirror-registry-cm.yaml

# Create the cluster image set. This will configure the CIM to look at your mirror registry as the source for release images
oc apply -f cluster-imageset.yaml

# Finally create the Agent Service Config. This is the database/storage service that will be used to house the customized agent.iso's that you can boot on your hw for discovery images
oc apply -f agent-config.yaml
```