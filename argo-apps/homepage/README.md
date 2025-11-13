## Simple NGINX deployment with static html sourced from a configMap

- Image used: `registry.redhat.io/ubi9/nginx-126` | https://github.com/sclorg/nginx-container/tree/master/1.26

- Adjust the kube resources to fit your environment. Kustomize is used simply to create `configMaps`. No other templating is involved
