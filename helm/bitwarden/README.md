## Example Bitwarden Helm v1.1.0 deployment on OpenShift disconnected

https://github.com/bitwarden/helm-charts/blob/main/charts/self-host/README.md

1. Add, update, and save the chart on the connected network. Can also just download from GitHub
```bash
helm repo add bitwarden https://charts.bitwarden.com/
helm repo update
helm pull bitwarden/self-host --untar
```

2. Grab the rawManifests example
```bash
wget https://bitwarden.com/assets/330r6BrWsFLL9FLZbPSLIc/badadefadd43ce575fd5f42221155786/rawManifests.yaml
```

## Mirror required images. Feel free to use my janky script, do it manually, or use oc-mirror
- If using the script, edit the conf file a bit and mirror away..
```bash
./podman-mirror-images.sh m2d mirror-bitwarden.conf
```

## Transfer all chart data, rawManifests, mirrored images, etc to disconnected network

## OpenShift config 
1. Set up namespace, service account, and add scc to service-account (not sure if every component needs to use the service account, I only applied it to the database)
```bash
oc create namespace bitwarden
oc create sa bitwarden-sa -n bitwarden
oc adm policy add-scc-to-user anyuid -z bitwarden-sa -n bitwarden
```

2. Create secrets 
> `SA_PASSWORD` must meet complexity requirements: "At least 8 characters including uppercase, lowercase letters, base-10 digits and/or non-alphanumeric symbols."
> https://learn.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-ver16

```bash
oc create secret generic custom-secret -n bitwarden \ 
--from-literal=globalSettings__installation__id="REPLACE" \ 
--from-literal=globalSettings__installation__key="REPLACE" \ 
--from-literal=globalSettings__mail__smtp__username="REPLACE" \
--from-literal=globalSettings__mail__smtp__password="REPLACE" \
--from-literal=globalSettings__yubico__clientId="REPLACE" \
--from-literal=globalSettings__yubico__key="REPLACE" \
--from-literal=globalSettings__hibpApiKey="REPLACE" \
--from-literal=SA_PASSWORD="Mssql!Passw0rd"
```

## Upload images to your internal registry
- If using the script, edit the conf file a bit and mirror away..
```bash
./podman-mirror-images.sh d2m mirror-bitwarden.conf
```

## Customize helm chart
1. Copy values.yaml and customize it for your env
```bash
cp self-host/values.yaml self-host/my-values.yaml
```

2. Add rawManifests.yaml to chart values and customize to env
```bash
cat rawManifests.yaml >> self-host/my-values.yaml
```

3. Edit the chart, OpenShift specific stuff has been annotated in the `ocp-values.yaml`, use those as a baseline for your values
> `grep -ne OCP ocp-values.yaml`
> `grep -ne mirrored-image ocp-values.yaml`

```bash
vim self-host/my-values.yaml
```

4. Install the chart to your cluster
```bash
helm install bitwarden --namespace bitwarden --values self-host/my-values.yaml ./self-host
```

