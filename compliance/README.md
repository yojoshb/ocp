## Compliance Operator: OCP4 DISA STIG

- https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/security_and_compliance/compliance-operator
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/security_and_compliance/compliance-operator#using-oc-compliance-plug-in
- https://github.com/ComplianceAsCode/compliance-operator/blob/master/doc/usage.md
- https://github.com/openshift/compliance-operator/blob/master/doc/tutorials/workshop/content/exercises/01-compliance-operator.md

### Setup and scan
1. Install Compliance Operator: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/security_and_compliance/compliance-operator#compliance-operator-installation

2. Switch to the openshift-compliance project
```bash
oc project openshift-compliance
```

3. List the bundled Profiles
```bash
oc get profiles
NAME                       AGE   VERSION
ocp4-bsi                   90d   2022
ocp4-bsi-2022              90d   2022
ocp4-bsi-node              90d   2022
ocp4-bsi-node-2022         90d   2022
ocp4-cis                   90d   1.7.0
ocp4-cis-1-7               90d   1.7.0
ocp4-cis-node              90d   1.7.0
ocp4-cis-node-1-7          90d   1.7.0
ocp4-e8                    90d
ocp4-high                  90d   Revision 4
ocp4-high-node             90d   Revision 4
ocp4-high-node-rev-4       90d   Revision 4
ocp4-high-rev-4            90d   Revision 4
ocp4-moderate              90d   Revision 4
ocp4-moderate-node         90d   Revision 4
ocp4-moderate-node-rev-4   90d   Revision 4
ocp4-moderate-rev-4        90d   Revision 4
ocp4-nerc-cip              90d
ocp4-nerc-cip-node         90d
ocp4-pci-dss               90d   3.2.1
ocp4-pci-dss-3-2           90d   3.2.1
ocp4-pci-dss-4-0           90d   4.0.0
ocp4-pci-dss-node          90d   3.2.1
ocp4-pci-dss-node-3-2      90d   3.2.1
ocp4-pci-dss-node-4-0      90d   4.0.0
ocp4-stig                  90d   V2R3  <-- We need this
ocp4-stig-node             90d   V2R3  <-- this..
ocp4-stig-node-v2r2        90d   V2R2
ocp4-stig-node-v2r3        90d   V2R3
ocp4-stig-v2r2             90d   V2R2
ocp4-stig-v2r3             90d   V2R3
rhcos4-bsi                 90d   2022
rhcos4-bsi-2022            90d   2022
rhcos4-e8                  90d
rhcos4-high                90d   Revision 4
rhcos4-high-rev-4          90d   Revision 4
rhcos4-moderate            90d   Revision 4
rhcos4-moderate-rev-4      90d   Revision 4
rhcos4-nerc-cip            90d
rhcos4-stig                90d   V2R3  <-- and this.
rhcos4-stig-v2r2           90d   V2R2
rhcos4-stig-v2r3           90d   V2R3
```

- You can inspect the profiles to view the rules they are set to invoke against:
```bash
oc get profiles -o yaml ocp4-stig
```

- You can view the rules like so:
```bash
oc get rules -o yaml ocp4-fips-mode-enabled-on-all-nodes
```

4. Create or use a `scansetting`. This is the resource that configures how scans will run
```bash
oc get scansettings
NAME                 AGE
default              90d
default-auto-apply   90d
```

- If your control-plane nodes aren't allowed to mount PV's, you'll probably want to create your own scansetting that schedules the 'result server pod' on a worker node 
```bash
cat <<EOF > rs-worker.yaml
apiVersion: compliance.openshift.io/v1alpha1
kind: ScanSetting
metadata:
  name: rs-worker-scan
  namespace: openshift-compliance
rawResultStorage:
  nodeSelector:
    node-role.kubernetes.io/worker: ""
  #storageClassName: nfs # <-- Required, if there is no default storageclass. If a default is set then this is Optional 
  pvAccessModes:
  - ReadWriteOnce
  rotation: 3
  size: 1Gi
  tolerations:
  - operator: Exists
roles:
- worker
- master
scanTolerations:
  - operator: Exists
schedule: 0 1 * * *
EOF
```
```bash
oc create -f rs-worker.yaml

# Check and make sure the scansetting is there
oc get scansettings rs-worker-scan -o yaml
```


5. Create a `scansettingbinding` resource to configure the scansetting to run the desired profile(s)
```bash
cat <<EOF > ssb-stig.yaml
apiVersion: compliance.openshift.io/v1alpha1
kind: ScanSettingBinding
metadata:
  name: stig
profiles:
  - name: ocp4-stig
    kind: Profile
    apiGroup: compliance.openshift.io/v1alpha1
  - name: ocp4-stig-node
    kind: Profile
    apiGroup: compliance.openshift.io/v1alpha1
  - name: rhcos4-stig
    kind: Profile
    apiGroup: compliance.openshift.io/v1alpha1
settingsRef:
  name: default # Here is where to specify what scansetting to apply this binding to
  kind: ScanSetting
  apiGroup: compliance.openshift.io/v1alpha1
EOF
```

6. Create the scan
```bash
oc create -f ssb-stig.yaml
scansettingbinding.compliance.openshift.io/stig created
```

7. Check the status
```bash
oc get compliancesuites -w
NAME   PHASE     RESULT
stig   RUNNING   NOT-AVAILABLE
```
```bash
oc get compliancescans -w
NAME                    PHASE      RESULT
ocp4-stig               RUNNING    NOT-AVAILABLE
ocp4-stig-node-master   RUNNING    NOT-AVAILABLE
ocp4-stig-node-worker   RUNNING    NOT-AVAILABLE
rhcos4-stig-master      RUNNING    NOT-AVAILABLE
rhcos4-stig-worker      RUNNING    NOT-AVAILABLE
```

8. When it's complete the status will change to DONE
```bash
oc get compliancesuites
NAME   PHASE   RESULT
stig   DONE    NON-COMPLIANT
```
```bash
oc get compliancescans
NAME                    PHASE   RESULT
ocp4-stig               DONE    NON-COMPLIANT
ocp4-stig-node-master   DONE    NON-COMPLIANT
ocp4-stig-node-worker   DONE    NON-COMPLIANT
rhcos4-stig-master      DONE    NON-COMPLIANT
rhcos4-stig-worker      DONE    NON-COMPLIANT
```
```bash
oc get events --field-selector reason=ResultAvailable
LAST SEEN   TYPE     REASON            OBJECT                    MESSAGE
23m         Normal   ResultAvailable   scansettingbinding/stig   The result is: NON-COMPLIANT
```

### Check and grab results

1. Check results
```bash
oc get compliancecheckresults
```

- You can use these commands to further filter compliancecheckresults
```bash
# Check the results for a specfic suite
oc get compliancecheckresults -l compliance.openshift.io/suite=stig

# Check the results for a specfic scan
oc get compliancecheckresults -l compliance.openshift.io/scan-name=ocp4-stig

# Check for PASS
oc get compliancecheckresults -l 'compliance.openshift.io/check-status=PASS'

# Check for FAIL
oc get compliancecheckresults -l 'compliance.openshift.io/check-status=FAIL'

# Check for MANUAL remediation
oc get compliancecheckresults -l 'compliance.openshift.io/check-status=MANUAL'

# Check for FAIL that can be applied through automated remediation
oc get compliancecheckresults -l 'compliance.openshift.io/check-status=FAIL,compliance.openshift.io/automated-remediation'

# Check for FAIL and filter by severity high. Adjust as needed
oc get compliancecheckresults -l 'compliance.openshift.io/check-status=FAIL,compliance.openshift.io/check-severity=high'
```

2. The XCCDF results are in configmaps. You can filter by scan and extract them
```bash
oc get cm -l=compliance.openshift.io/scan-name=ocp4-stig
oc get cm -l=compliance.openshift.io/scan-name=rhcos4-stig-master
oc get cm -l=compliance.openshift.io/scan-name=rhcos4-stig-worker
# ...
```

```bash
oc extract cm/ocp4-stig-api-check
```

3. Obtain the raw results from the persistent volume(s)
```bash
oc get compliancesuites stig -o json | jq '.status.scanStatuses[].resultsStorage'
{
  "name": "ocp4-stig",
  "namespace": "openshift-compliance"
}
{
  "name": "ocp4-stig-node-worker",
  "namespace": "openshift-compliance"
}
{
  "name": "ocp4-stig-node-master",
  "namespace": "openshift-compliance"
}
{
  "name": "rhcos4-stig-worker",
  "namespace": "openshift-compliance"
}
{
  "name": "rhcos4-stig-master",
  "namespace": "openshift-compliance"
}
```

- Then use that PVC name to locate the results
```bash
oc get pvc -n openshift-compliance ocp4-stig
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                VOLUMEATTRIBUTESCLASS   AGE
ocp4-stig   Bound    pvc-c15a2d03-6479-4411-afee-92a1904d0e56   1Gi        RWO            ocs-storagecluster-cephfs   <unset>                 86m
```

- You can fetch all of them with some more bash
```bash
oc get compliancesuites stig -o json | jq -r '.status.scanStatuses[].resultsStorage.name' | xargs oc get pvc
NAME                    STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                VOLUMEATTRIBUTESCLASS   AGE
ocp4-stig               Bound    pvc-c15a2d03-6479-4411-afee-92a1904d0e56   1Gi        RWO            ocs-storagecluster-cephfs   <unset>                 92m
ocp4-stig-node-worker   Bound    pvc-5bb9bcbf-f930-46e2-aa0b-564c49fbb510   1Gi        RWO            ocs-storagecluster-cephfs   <unset>                 92m
ocp4-stig-node-master   Bound    pvc-c4f89132-69f1-4e95-9f50-424afabcd2f8   1Gi        RWO            ocs-storagecluster-cephfs   <unset>                 92m
rhcos4-stig-worker      Bound    pvc-209cefa9-f3ab-4485-a7c7-f22e18f00635   1Gi        RWO            ocs-storagecluster-cephfs   <unset>                 92m
rhcos4-stig-master      Bound    pvc-42d6721d-8cba-4bf6-8707-57d374439976   1Gi        RWO            ocs-storagecluster-cephfs   <unset>                 92m
```

4. To pull the raw results, we'll have to spin a pod up to rip'em out of the PVC(s). This pod is mounting all PVCs 
```bash
cat <<EOF > pv-extract-pod.yaml
apiVersion: "v1"
kind: Pod
metadata:
  name: pv-extract
spec:
  securityContext:
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: pv-extract-pod
      image: registry.redhat.io/ubi9/ubi
      command: ["sleep", "3000"]
      volumeMounts:
      - mountPath: "/ocp4-stig"
        name: ocp4-stig-vol
      - mountPath: "/ocp4-stig-node-worker"
        name: ocp4-stig-node-worker-vol
      - mountPath: "/ocp4-stig-node-master"
        name: ocp4-stig-node-master-vol
      - mountPath: "/rhcos4-stig-worker"
        name: rhcos4-stig-worker-vol
      - mountPath: "/rhcos4-stig-master"
        name: rhcos4-stig-master-vol
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop: [ALL]
  volumes:
    - name: ocp4-stig-vol
      persistentVolumeClaim:
        claimName: ocp4-stig
    - name: ocp4-stig-node-worker-vol
      persistentVolumeClaim:
        claimName: ocp4-stig-node-worker
    - name: ocp4-stig-node-master-vol
      persistentVolumeClaim:
        claimName: ocp4-stig-node-master
    - name: rhcos4-stig-worker-vol
      persistentVolumeClaim:
        claimName: rhcos4-stig-worker
    - name: rhcos4-stig-master-vol
      persistentVolumeClaim:
        claimName: rhcos4-stig-master
EOF
```

- Create the pod and wait for it to be ready
```bash
oc create -f pv-extract-pod.yaml; oc wait --for=condition=ready pod/pv-extract
```

5. Now we can extract the contents out of the pod using `oc cp <pod>/<mount_path>` to our current directory
```bash
for pv in $(oc get compliancesuites stig -o json | jq -r '.status.scanStatuses[].resultsStorage.name'); do oc cp pv-extract:$pv .; echo "$pv extracted"; done
```

6. Delete the pod once the data has been extracted. Since these volumes are RWO, only one pod can mount the PVCs at a time. The operator will continue storing results in these PVCs
```bash
oc delete pod/pv-extract
```

7. You should see a new directory with all of the `bzip2` files.
```bash
tree 0/
0/
├── ocp4-stig-api-checks-pod.xml.bzip2
├── ocp4-stig-node-master-m1.ocp.lab.io-pod.xml.bzip2
├── ocp4-stig-node-master-m2.ocp.lab.io-pod.xml.bzip2
├── ocp4-stig-node-master-m3.ocp.lab.io-pod.xml.bzip2
├── ocp4-stig-node-worker-w1.ocp.lab.io-pod.xml.bzip2
├── ocp4-stig-node-worker-w2.ocp.lab.io-pod.xml.bzip2
├── ocp4-stig-node-worker-w3.ocp.lab.io-pod.xml.bzip2
├── rhcos4-stig-master-m1.ocp.lab.io-pod.xml.bzip2
├── rhcos4-stig-master-m2.ocp.lab.io-pod.xml.bzip2
├── rhcos4-stig-master-m3.ocp.lab.io-pod.xml.bzip2
├── rhcos4-stig-worker-w1.ocp.lab.io-pod.xml.bzip2
├── rhcos4-stig-worker-w2.ocp.lab.io-pod.xml.bzip2
└── rhcos4-stig-worker-w3.ocp.lab.io-pod.xml.bzip2

0 directories, 13 files
```

8. Not sure if it's a RHEL9 thing, but I needed to change the extension name for the `bzip2` tool to extract these correctly.
```bash
for file in $(find . -name *.bzip2); do mv -- "$file" "${file%.bzip2}.bz2"; done
```

9. Then just extract the files revealing the raw ARF file, keeping the original bz2 files present. 
```bash
for bz2 in $(find . -name *.bz2); do bzip2 -dk $bz2; done
```

### Check and apply remediations
Just like the `compliancecheckresults`, we can target the remediations

```bash
oc get complianceremediations
```

```bash
# Check remediations for a suite
oc get complianceremediations -l compliance.openshift.io/suite=stig

# Check remediations for a scan
oc get complianceremediations -l compliance.openshift.io/scan-name=rhcos4-stig
```

1. If you are applying multiple remediations, it's probably best to pause the MachineConfigPools as many of these remediations cause the need for nodes to reboot

- Pause Workers
```bash
oc patch machineconfigpools worker -p '{"spec":{"paused":true}}' --type=merge
```

- Pause Masters
```bash
oc patch machineconfigpools master -p '{"spec":{"paused":true}}' --type=merge
```

2. All you have to do is flip the `apply` attribute to `true`. Example for the `rhcos4-stig-master-service-sshd-disabled` rule:
```bash
oc get complianceremediations rhcos4-stig-master-service-sshd-disabled -o yaml
apiVersion: compliance.openshift.io/v1alpha1
kind: ComplianceRemediation
metadata:
  creationTimestamp: "2026-04-20T18:37:09Z"
  generation: 1
  labels:
    compliance.openshift.io/scan-name: rhcos4-stig-master
    compliance.openshift.io/suite: stig
  name: rhcos4-stig-master-service-sshd-disabled
  namespace: openshift-compliance
  ownerReferences:
  - apiVersion: compliance.openshift.io/v1alpha1
    blockOwnerDeletion: true
    controller: true
    kind: ComplianceCheckResult
    name: rhcos4-stig-master-service-sshd-disabled
    uid: 82668356-8b90-4fc9-a049-622d6e19471e
  resourceVersion: "126059393"
  uid: b96e5962-39da-42ce-9912-879550897e7d
spec:
  apply: false # <-- Set to 'true' to apply
  current:
    object:
      apiVersion: machineconfiguration.openshift.io/v1
      kind: MachineConfig
      spec:
        config:
          ignition:
            version: 3.1.0
          systemd:
            units:
            - enabled: false
              mask: true
              name: sshd.service
            - enabled: false
              mask: true
              name: sshd.socket
  outdated: {}
  type: Configuration
status:
  applicationState: NotApplied
```

```bash
oc edit complianceremediations rhcos4-stig-master-service-sshd-disabled
```
Or
```bash
oc patch complianceremediations rhcos4-stig-master-service-sshd-disabled -p '{"spec":{"apply":true}}' --type=merge
```

3. When finished, unpause the affected MachineConfigPool for changes to be applied
```bash
# Worker
oc patch machineconfigpools worker -p '{"spec":{"paused":false}}' --type=merge

# Master
oc patch machineconfigpools master -p '{"spec":{"paused":false}}' --type=merge
```

4. If you want to apply all rules that can be auto remedied, at the suite level you can set your scansetting to auto apply remediations
```bash
oc patch scansettings rs-worker -p '{"autoApplyRemediations":true}' --type=merge
```

### Tailored Profiles
Disable rules in a profile to further modify the profiles

1. List rules in a targeted profile
```bash
oc get profiles -o yaml rhcos4-stig

# List the rule you want to target and inspect it
oc get rules rhcos4-service-sshd-disabled -o yaml
```

2. Create a tailored profile
```bash
cat << EOF > rhcos4-stig-tailored.yaml
apiVersion: compliance.openshift.io/v1alpha1
kind: TailoredProfile
metadata:
  name: rhcos4-stig-tailored
  namespace: openshift-compliance
spec:
  description: Tailored profile for my Org
  extends: rhcos4-stig # <-- This is important to target the correct profile you are tailoring
  title: RHCOS4 STIG profile disables sshd login
  disableRules:
    - name: rhcos4-service-sshd-disabled
      rationale: Needed for troubleshooting during network testing
EOF
```

3. Add that tailored profile to your scan binding. You can edit the existing one, but if you create a new one scans will be rolled out immediatley
```bash
cat << EOF > rhcos4-stig-tailored.yaml
apiVersion: compliance.openshift.io/v1alpha1
kind: ScanSettingBinding
metadata:
  name: stig
profiles:
  - name: ocp4-stig
    kind: Profile
    apiGroup: compliance.openshift.io/v1alpha1
  - name: ocp4-stig-node
    kind: Profile
    apiGroup: compliance.openshift.io/v1alpha1
  - name: rhcos4-stig-tailored
    kind: TailoredProfile
    apiGroup: compliance.openshift.io/v1alpha1
settingsRef:
  name: rs-worker-scan
  kind: ScanSetting
  apiGroup: compliance.openshift.io/v1alpha1
EOF
```

4. Apply the new scanbinding
```bash
oc delete scansettingbindings --all
oc create -f rhcos4-stig-tailored.yaml
```

### Re-run scan
You can rerun a scan at any time by adding an annotation to the compliancescan 

```bash
oc get compliancescan
NAME                    PHASE   RESULT
ocp4-stig               DONE    NON-COMPLIANT
ocp4-stig-node-master   DONE    NON-COMPLIANT
ocp4-stig-node-worker   DONE    NON-COMPLIANT
rhcos4-stig-master      DONE    NON-COMPLIANT
rhcos4-stig-worker      DONE    NON-COMPLIANT
```
```bash
oc annotate compliancescan ocp4-stig compliance.openshift.io/rescan=
```
```bash
oc get compliancescans -w
NAME                    PHASE     RESULT
ocp4-stig               RUNNING   NOT-AVAILABLE
ocp4-stig-node-master   DONE      NON-COMPLIANT
ocp4-stig-node-worker   DONE      NON-COMPLIANT
rhcos4-stig-master      DONE      NON-COMPLIANT
rhcos4-stig-worker      DONE      NON-COMPLIANT
```
