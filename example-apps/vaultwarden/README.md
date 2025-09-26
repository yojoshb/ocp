### Example deployment for Vaultwarden
[Github Project](https://github.com/dani-garcia/vaultwarden)

- Change values to match your environment as needed i.e `image`, `persistentVolumeClaim`, `storageClassName`, route `host`

```bash
# Apply the deployment
oc apply -f vaultwarden.yaml
```
