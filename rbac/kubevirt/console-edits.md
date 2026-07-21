```bash
oc edit console.operator.openshift.io cluster
```

```yaml
spec:
  plugins:
    - kubevirt-plugin
  customization:
    perspectives:
    - id: admin
      visibility:
        state: Disabled
        disabledPredictates:
        - groupIs: ocp-virt-admins
```