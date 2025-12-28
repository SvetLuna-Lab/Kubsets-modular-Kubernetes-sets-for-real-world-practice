# Kubsets — “Kubernetes sets” on practice (Kind + manifests)
![CubeSat 1U](assets/cubesat.jpg)
A compact, **hands-on** Kubernetes sandbox where each “kubset” is a focused scenario:
Deployment + Service + ConfigMap, StatefulSet (Postgres), DaemonSet agent, one-shot Job, CronJob heartbeat — all runnable locally via **Kind**.

This repo is built to be:
- **repeatable** (one command brings the whole stack up),
- **observable** (logs + status paths are explicit),
- **interview-ready** (small, realistic, explainable).

> Side note: `assets/cubesat.jpg` is used as a “COMMS-first” metaphor from my CubeSat track:  
> **if you can’t communicate, the mission doesn’t exist.**  
> Kubernetes is similar: if you can’t observe and reason about the system, you can’t operate it.

---

## What’s inside

### Workloads (one namespace: `kubsets`)
- **web** — Deployment + Service (simple app to produce logs/telemetry)
- **postgres** — StatefulSet + Service (stable identity/storage semantics demo)
- **node-agent** — DaemonSet (runs on every node, shows “per-node” workloads)
- **migrate** — Job (one-shot operation example)
- **heartbeat** — CronJob (periodic jobs, scheduler behavior)

---

## Repository structure
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
- `kind`
- `kubectl`

Optional:
- `curl` (for local HTTP check)

---

## Quick start

### 1) Create local cluster
```bash
make kind-up
```

### 2) Deploy everything
```bash
make deploy
```

### 3) Check status
```bash
make status
```

### 4) Minimal smoke check
```bash
make smoke
```

### 5) Watch web telemetry (logs)
```bash
make logs-web
```

### 6) Tear down
```bash
make destroy
make kind-down
```
### Demo scenario (2 minutes)

This is the exact “show flow” that fits a short screen-share.
```bash
make kind-up
make deploy
make status
make logs-web          # telemetry / “system voice”
make logs-migrate       # one-shot Job
make cron-jobs          # CronJob creates Jobs over time
make showcase           # prints a clean demo output block
make destroy
make kind-down
```
### What you should capture for a small “showcase” section:

- Screenshot: kubectl get all -n kubsets

- 2–3 lines: kubectl logs -n kubsets deploy/web --tail=20

### Make targets

- make kind-up / make kind-down — create/delete Kind cluster

- make deploy / make destroy — apply/delete whole namespace

- make status — pods/services/events snapshot

- make logs-web — follow logs from web

- make logs-agent — follow logs from DaemonSet agent

- make logs-migrate — logs from one-shot job

- make cron-jobs — show CronJobs and Jobs

- make pf-web — port-forward web to localhost:8080

- make smoke — waits for readiness (deployment/sts/job) + cronjob presence

- make showcase — prints a “clean output block” for a demo

- make clean — deletes completed Jobs (local cleanup)


### Troubleshooting

See: docs/troubleshooting.md
It includes at least these typical cases:

- CrashLoopBackOff

- ImagePullBackOff

- Job stuck

- DB not ready

- Service has no endpoints

- Kind cluster not reachable

- DaemonSet not scheduled

- CronJob not running

- PVC Pending

- Namespace delete stuck


### Design principles

See: docs/principles.md
(Short rules: isolation by namespace, no shared mutable state between pods, explicit health/readiness, and a predictable debug path.)


### Roadmap

See: docs/roadmap.md

Planned expansions:

- Networking kubset (ingress, network policies, traffic shaping)

- Storage kubset (PVC classes, backup/restore, migration patterns)

- Security kubset (RBAC, PodSecurity, secrets patterns, least privilege)

- optional: lightweight CI smoke (kind-in-ci or manifest validation)


### License

MIT — see LICENSE.
