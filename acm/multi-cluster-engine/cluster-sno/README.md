### Host infra with static networking
https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.14/html-single/clusters/index#create-host-inventory-cli

https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.14/html-single/clusters/index#on-prem-creating-your-cluster-with-the-cli-nmstateconfig

https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.14/html-single/clusters/index#auto-add-host-host-inventory

1. Edit configs where needed and apply them

```bash
oc apply -f ns.yaml

oc apply -f nmstate.yaml

oc apply -f infra-env.yaml
```

2. Create a discovery iso and boot it on your hw

> Note: There is a current issue with the RHCOS images not trusting signatures.
> There is fix in place but not yet pushed into stable codebase: https://github.com/openshift/assisted-service/pull/7807/files

- The agent.service will most likely be failing to pull the multi-cluster-engine images to register the host with ACM. SSH into the host(s) and remove the redhat configs out of `/etc/containers/policy.json`

Change this:
```json
# /etc/containers/policy.json
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ],
    "transports": {
        "docker": {
            "registry.access.redhat.com": [
                {
                    "type": "signedBy",
                    "keyType": "GPGKeys",
                    "keyPaths": ["/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release", "/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta"]
                }
            ],
            "registry.redhat.io": [
                {
                    "type": "signedBy",
                    "keyType": "GPGKeys",
                    "keyPaths": ["/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release", "/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta"]
                }
            ]
        },
        "docker-daemon": {
            "": [
                {
                    "type": "insecureAcceptAnything"
                }
            ]
        }
    }
}
```

To this:
```json
# /etc/containers/policy.json
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ],
    "transports": {
        "docker-daemon": {
            "": [
                {
                    "type": "insecureAcceptAnything"
                }
            ]
        }
    }
}
```

The agent then should succeed, and you'll be able to join the discovered host to the inventory.