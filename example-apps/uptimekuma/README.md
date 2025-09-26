### Example deployment for Uptime Kuma
[Github Project](https://github.com/louislam/uptime-kuma)

- Change values to match your environment as needed i.e `image`, `persistentVolumeClaim`, `storageClassName`, route `host`

- Note: This container will effectively be running as root, since the Dockerfile was built without a USER specified. 

```bash
# Create the namespace
oc apply -f ns.yaml

# Create a serviceaccount named 'uptime-kuma-sa' in the uptime-kuma namespace
oc create sa uptime-kuma-sa -n uptime-kuma

# Add the anyuid policy to the service account in the uptime-kuma namespace
oc adm policy add-scc-to-user anyuid -z uptime-kuma-sa -n uptime-kuma

# Apply the deployment
oc apply -f uptime-kuma.yaml
```
