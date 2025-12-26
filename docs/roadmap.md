# Roadmap

This roadmap describes how **kubsets** evolves from a minimal educational stack
into a practical, reusable Kubernetes training kit.

Principle: each step must be **repeatable**, **observable**, and **debuggable**.

---

## v0.1 — Core (done)
**Goal:** a small, deterministic baseline that demonstrates Kubernetes primitives.

- Kind cluster configuration (`kind/cluster.yaml`)
- Single namespace (`k8s/00-namespace.yaml`)
- Web app:
  - ConfigMap
  - Deployment
  - Service
- Postgres storage (StatefulSet + Service)
- DaemonSet node agent (per-node telemetry)
- Job example (migration)
- CronJob example (heartbeat)
- Makefile for one-command workflows
- Troubleshooting guide with typical failure cases

Deliverable:
- `make kind-up && make deploy && make smoke`

---

## v0.2 — Observability & Operations
**Goal:** turn the demo into a small operational playground.

- Add liveness/readiness probes
- Add resource requests/limits
- Add basic PodSecurityContext
- Add structured logging conventions
- Add a minimal `/healthz` and `/metrics` endpoint
- Add a "status" command group in Makefile
- Add a short `docs/runbook.md` (what to check first)

Deliverable:
- reliable rollout / rollback flow + clear status signals

---

## v0.3 — Networking Kubset
**Goal:** introduce networking patterns safely.

- Ingress (kind-friendly, e.g. ingress-nginx) or port-forward cookbook
- NetworkPolicy (deny-by-default + allow required flows)
- Service types comparison (ClusterIP vs NodePort)
- DNS discovery examples

Deliverable:
- clear networking lab with expected outcomes

---

## v0.4 — Storage Kubset
**Goal:** introduce persistence patterns and failure modes.

- StorageClass notes for kind
- PVC expansion notes (if supported)
- Backup/restore workflow sample (logical dump)
- StatefulSet upgrade scenario and pitfalls

Deliverable:
- DB durability lab + recovery story

---

## v0.5 — Packaging & Reuse
**Goal:** make kubsets reusable as a template for new projects.

- Optional Kustomize overlays
- Optional Helm chart (lightweight)
- CI checks (YAML lint, kubeconform, basic smoke)
- Release tags + changelog conventions

Deliverable:
- `kubsets` usable as an onboarding kit or interview demo

---

## Longer-term ideas (optional)
- Multi-namespace layout and RBAC examples
- Secrets management (SealedSecrets or external secret operators — demo only)
- GitOps workflow (ArgoCD/Flux) — concept-only
- Multi-arch builds, registry workflow

---

## Non-goals
- Production-grade security hardening (beyond minimal safe defaults)
- Complex service mesh setups
- Vendor-specific cloud deployment in this repo

This repository is meant to remain: **small, sharp, testable**.
