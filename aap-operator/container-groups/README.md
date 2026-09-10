## Instance Groups
By default, the operator will create a `default` container group to run jobs. These are ephemeral containers. 

### krb5.conf configmap
Useful when automating against Windows hosts using Kerberos. This is an alternative method to map a krb5.conf file into an execution environment rather than creating a custom execution environment with the krb5.conf imbedded. 

1. Create a configmap that holds the contents of the krb5.conf file
```
# Example krb5.conf
[libdefaults]
  rdns = false
  default_realm = EXAMPLE.COM

[realms]
  EXAMPLE.COM = {
    kdc = dc.example.com
    admin_server = dc.example.com
  }
```
```bash
oc create configmap krb5-config --from-file=krb5.conf=./krb5.conf -n <aap-namespace>
```

2. Inject the configmap into the container group

AAP Controller UI > Instance Groups > Edit `default` > Customize pod spec

- Customize the pod spec, the configmap portion to add is commented
```yaml
apiVersion: v1
kind: Pod
metadata:
  namespace: <aap-namespace>
spec:
  ...
  containers:
    - image: >-
        registry.redhat.io/ansible-automation-platform-27/ee-supported-rhel9@sha256:blahblahblah
      name: worker
      args:
        - ansible-runner
        - worker
        - '--private-data-dir=/runner'
      resources:
        requests:
          cpu: 250m
          memory: 100Mi
      
      # Add the mountpath and subpath
      volumeMounts:
        - name: krb5-volume
          mountPath: /etc/krb5.conf
          subPath: krb5.conf
  
  # Define the volume from the configmap
  volumes:
    - name: krb5-volume
      configMap:
        name: krb5-config
        items:
          - key: krb5.conf
            path: krb5.conf
```

3. Now there's a valid krb5.conf in the pod during execution
