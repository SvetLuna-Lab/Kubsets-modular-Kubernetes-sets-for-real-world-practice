# Troubleshooting Guide

This document lists **common failure scenarios** you may encounter while working
with kubsets and provides **minimal, practical debugging steps**.

The goal is not to fix everything automatically,
but to help you **understand what is broken and why**.

---

## 1. Pod in `CrashLoopBackOff`

**Symptoms**
- Pod restarts repeatedly
- `STATUS: CrashLoopBackOff`

**Checks**
```bash
kubectl logs <pod>
kubectl describe pod <pod>
```

**Typical causes**

- Application error

- Missing environment variable

- ConfigMap not mounted

- Port mismatch

## 2. ImagePullBackOff

**Symptoms**

- Pod stuck in ImagePullBackOff

- Image never starts

**Checks**
```bash
kubectl describe pod <pod>
```

**Typical causes**

- Wrong image name or tag

- Image not built locally (for kind)

- Missing registry access

For kind: ensure the image is loaded into the cluster.

## 3. Job stuck (never completes)

**Symptoms**

- Job stays in Running

- No completion event

**Checks**
```bash
kubectl logs job/<job-name>
kubectl describe job <job-name>
```

**Typical causes**

- Script waiting for dependency

- Database not ready

- Infinite loop or blocking command


## 4. Database not ready

**Symptoms**

- Application cannot connect to DB

- Connection refused or timeout

**Checks**
```bash
kubectl get pods
kubectl logs <db-pod>
kubectl describe pod <db-pod>
```

**Typical causes**

- Init container not finished

- Wrong credentials

- Volume not mounted


## 5. Service has no endpoints

**Symptoms**

- Service exists

- No traffic reaches pods

**Checks**
```bash
kubectl get endpoints <service-name>
kubectl get pods --show-labels
```

**Typical causes**

- Selector mismatch

- Pods not ready

- Wrong labels

## 6. Kind cluster not reachable

**Symptoms**

- kubectl cannot connect

- Context errors

**Checks**
```bash
kubectl config get-contexts
kubectl cluster-info
```

**Typical causes**

- Kind cluster stopped

- Wrong kubeconfig context

- Docker daemon not running

## 7. DaemonSet agent not scheduled

**Symptoms**

- No pods created for DaemonSet

**Checks**
```bash
kubectl describe daemonset <name>
kubectl get nodes
```

**Typical causes**

- Node selector mismatch

- Taints not tolerated

- Resource limits too strict

## 8. CronJob not running

**Symptoms**

- CronJob exists

- No Jobs created

**Checks**
```bash
kubectl describe cronjob <name>
kubectl get jobs
```

**Typical causes**

- Wrong schedule expression

- Suspended CronJob

- Controller issues

## 9. PVC in Pending

**Symptoms**

- Pod waiting for volume

- PVC never bound

**Checks**
```bash
kubectl describe pvc <name>
kubectl get storageclass
```

**Typical causes**

- No default StorageClass

- Unsupported volume type (kind)

- StorageClass mismatch

## 10. Namespace deletion stuck

**Symptoms**

- Namespace stuck in Terminating

**Checks**
```bash
kubectl get namespace <name> -o yaml
```

**Typical causes**

- Finalizers not removed

- Stuck resources inside namespace

**Emergency cleanup**
```bash
kubectl delete namespace <name> --grace-period=0 --force
```

## Final Note

Troubleshooting is not a failure.
It is normal Kubernetes operation.

If you understand:

- what failed

- where to look

- how to verify

then the system is working as designed.
