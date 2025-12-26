# Kubsets — Kubernetes “sets” in practice

![CubeSat 1U](assets/cubesat.jpg)

**kubsets** is a hands-on, minimal-but-real collection of Kubernetes “sets” (small, composable stacks) designed to teach and demonstrate core workload patterns **by running them locally**.

The guiding metaphor is **CubeSat engineering**:

> **COMMS-first**: in small systems, reliability comes from a clear signal chain, strict interfaces, and measurable behavior.  
> In Kubernetes, that means: reproducible manifests, observable workloads, safe defaults, and explicit lifecycle flows.

---

## Why this repo exists

- **Learning by building:** you deploy and operate a tiny platform end-to-end.
- **Patterns, not toys:** includes the most common workload controllers:
  - `Deployment` (stateless web)
  - `StatefulSet` (Postgres)
  - `DaemonSet` (node agent)
  - `Job` (one-off migration)
  - `CronJob` (scheduled heartbeat)
- **No magic:** plain YAML manifests; no Helm required.
- **Local-first:** runs on `kind` (Kubernetes in Docker).

---

## What you get (the “plushies”)

### 1) A complete “mini-platform” you can spin up locally
- Namespace-scoped, reproducible.
- Clear separation of concerns: app / db / node agent / migrations / scheduled tasks.

### 2) “COMMS-first” operational discipline
- Readable logs as telemetry.
- Deterministic apply/delete workflow.
- Manifests numbered for a clear lifecycle.

### 3) Ready-made structure for expansion
- Add more kubsets (networking, storage, security) without breaking the core.

---

## Repository layout
```text
kubsets/
├─ README.md
├─ LICENSE
├─ .gitignore
├─ Makefile
├─ assets/
│ └─ cubesat.jpg
├─ kind/
│ └─ cluster.yaml
├─ app/
│ ├─ server.py
│ └─ Dockerfile
└─ k8s/
├─ 00-namespace.yaml
├─ 05-configmap.yaml
├─ 10-deployment-web.yaml
├─ 15-service-web.yaml
├─ 20-statefulset-db.yaml
├─ 25-service-db.yaml
├─ 30-daemonset-agent.yaml
├─ 40-job-migrate.yaml
└─ 50-cronjob-heartbeat.yaml
```

---

## Prerequisites

- Docker
- `kubectl`
- `kind`
- (optional) `make`

---

## Quick start (local cluster + deploy)

### 1) Create a local cluster
```bash
kind create cluster --config kind/cluster.yaml
kubectl cluster-info
```

## 2) Deploy everything

Apply in order (recommended):
```bash
kubectl apply -f k8s/00-namespace.yaml
kubectl apply -f k8s/05-configmap.yaml
kubectl apply -f k8s/10-deployment-web.yaml
kubectl apply -f k8s/15-service-web.yaml
kubectl apply -f k8s/20-statefulset-db.yaml
kubectl apply -f k8s/25-service-db.yaml
kubectl apply -f k8s/30-daemonset-agent.yaml
kubectl apply -f k8s/40-job-migrate.yaml
kubectl apply -f k8s/50-cronjob-heartbeat.yaml
```

## 3) Check status (“telemetry”)
```bash
kubectl get all -n kubsets
kubectl get pods -n kubsets -o wide
```   

## 4) Watch logs

Web:
```bash
kubectl logs -n kubsets deploy/web -f
```

Migration Job:
```bash
kubectl logs -n kubsets job/migrate -f
```

CronJob runs as Jobs; list them:
```bash
kubectl get jobs -n kubsets
```

## What each manifest demonstrates

**00-namespace.yaml**

- A dedicated namespace (clean isolation).
This is your “satellite bus”: everything else lives inside it.


**05-configmap.yaml**

- Config injection into pods (non-secret configuration).


**10-deployment-web.yaml + 15-service-web.yaml**

Stateless service pattern:

- Rolling updates

- Stable Service endpoint

- Easy scaling


**20-statefulset-db.yaml + 25-service-db.yaml**

Stateful workload pattern:

- Stable identity (pod names)

- Stable storage semantics (if PVCs are used)

- DB as a service dependency


**30-daemonset-agent.yaml**

Node-level pattern:

- One pod per node

- “Fleet telemetry agent” idea (logs/metrics/health hooks)


**40-job-migrate.yaml**

One-off lifecycle action:

- Schema init / migration / data seed pattern

- Safe to re-run depending on your migration logic


**50-cronjob-heartbeat.yaml**

Scheduled lifecycle action:

- Periodic heartbeat, cleanup, or maintenance job

- Demonstrates time-based automation in cluster


## Operating model (COMMS-first rules)

- Everything is observable: you should be able to answer:

   - what is running?

   - what failed?

   - where is the log?

   - what changed?

- No silent coupling: app ↔ db must be visible through services/env/config.

- Numbered manifests = deterministic lifecycle: apply and delete predictably.


## Cleanup

Delete workloads (reverse order is safer):
```bash
kubectl delete -f k8s/50-cronjob-heartbeat.yaml
kubectl delete -f k8s/40-job-migrate.yaml
kubectl delete -f k8s/30-daemonset-agent.yaml
kubectl delete -f k8s/25-service-db.yaml
kubectl delete -f k8s/20-statefulset-db.yaml
kubectl delete -f k8s/15-service-web.yaml
kubectl delete -f k8s/10-deployment-web.yaml
kubectl delete -f k8s/05-configmap.yaml
kubectl delete -f k8s/00-namespace.yaml
```

Remove cluster:
```bash
kind delete cluster
```

## Roadmap (next kubsets)

- kubset-002-networking

- Ingress, NetworkPolicy, DNS patterns, service discovery

- kubset-003-storage

- PVCs, StorageClass notes, backup/restore workflow

- kubset-004-security

- RBAC, ServiceAccounts, PodSecurity, image policies

- kubset-005-observability

- Metrics/logging hooks, minimal dashboards, alert rules

## Demo scenario (2 minutes)

```bash
make kind-up
make deploy
make status

# Web telemetry (sample logs)
make logs-web

# One-shot migration Job logs
make logs-migrate

# CronJob should create Jobs
make cron-jobs

# Cleanup
make destroy
make kind-down
```

**Smoke check (no CI)**
```bash
make kind-up
make deploy

# Web must become Available
kubectl wait -n kubsets --for=condition=available deploy/web --timeout=120s

# Migration Job must complete (if you run it)
kubectl wait -n kubsets --for=condition=complete job/migrate --timeout=180s

# CronJob must exist
kubectl get -n kubsets cronjob heartbeat

# Optional quick probe
# (if you have port-forward target) make port-forward && curl -s localhost:8080/health

```
**Quick “showcase” artifacts (optional but recommended)**

- assets/kubectl-get-all.png — output of:
```bash
kubectl get all -n kubsets
```

- assets/web-logs.png — a few lines from:
```bash
make logs-web
```
**What I would extend next**

- Networking: Ingress/HTTP routing, NetworkPolicies, mTLS-ready layout.

- Storage: PVC + StorageClass examples, backup/restore job patterns.

- Security: RBAC minimal roles, PodSecurity admission baseline, secret handling patterns.

- Observability: Prometheus scrape annotations, structured logs, simple dashboards.


## License

MIT — see LICENSE.

