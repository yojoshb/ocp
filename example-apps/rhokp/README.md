## Red Hat Offline Knowledge Portal on OpenShift
https://developers.redhat.com/articles/2025/10/03/how-deploy-offline-knowledge-portal-openshift

### 1. Login and download the image
Requires a Satellite Subscription. Also need to generate a Access Key: https://access.redhat.com/offline/access

```bash
podman login registry.redhat.io 
```

```bash
podman pull registry.redhat.io/offline-knowledge-portal/rhokp-rhel9:latest 
```

```bash
podman save --format oci-archive -o rhokp.tar registry.redhat.io/offline-knowledge-portal/rhokp-rhel9:latest
```

### 2. Move the image to the high-side and load it
```bash
podman load -i rhokp.tar
```

```bash
podman push registry.redhat.io/offline-knowledge-portal/rhokp-rhel9:latest registry.example.com/offline-knowledge-portal/rhokp-rhel9:latest
```

### 3. Deploy on the cluster
```bash
oc new-project rhokp
```

- Create a secret that can store your access key
```bash
oc create secret generic access-key --from-literal=access-key=<YOUR_ACCESS_KEY> -n rhokp
```

- Create the Deployment, service, and route
```bash
apiVersion: v1
kind: Service
metadata:
  name: rhokp
  namespace: rhokp
spec:
  selector:
    app: rhokp
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rhokp
  namespace: rhokp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rhokp
  template:
    metadata:
      labels:
        app: rhokp
    spec:
      containers:
        - name: rhokp
          image: registry.example.com/offline-knowledge-portal/rhokp-rhel9:latest # Change to your actual registry
          env:
            - name: ONLINE_VIEW
              value: 'false'
            - name: UNCLASSIFIED_BANNER
              value: 'true'
            - name: ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: access-key
                  key: access-key
          ports:
            - containerPort: 8080
              protocol: TCP
```