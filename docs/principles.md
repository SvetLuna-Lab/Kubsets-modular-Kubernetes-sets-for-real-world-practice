# Kubsets Principles

## What is a Kubset

A **kubset** is a minimal, self-contained Kubernetes stack designed to demonstrate
one clear operational idea using real manifests.

Kubsets are:
- small
- explicit
- runnable
- educational by design

Each kubset answers one question:
> *“How does this Kubernetes concept work in practice?”*

---

## Core Philosophy

### 1. Explicit is better than clever
Kubsets avoid hidden abstractions.
No Helm, no operators, no generators by default.

You should be able to read YAML and understand:
- what runs
- where it runs
- why it exists

---

### 2. Order matters
Kubernetes is declarative, but **human workflow is sequential**.

Kubsets are numbered to reflect safe application order:

00 - namespace
05 - config
10 - deployment
15 - service
20 - statefulset
25 - service
30 - daemonset
40 - job
50 - cronjob


This mirrors real operational thinking:
- define scope
- define configuration
- deploy workloads
- expose services
- run background and maintenance tasks

---

### 3. One responsibility per manifest
Each manifest should have **one clear role**.

Good:
- `deployment-web.yaml`
- `statefulset-db.yaml`
- `cronjob-heartbeat.yaml`

Bad:
- one file doing many unrelated things

This improves:
- reviewability
- debugging
- teaching value

---

### 4. Reproducible on a laptop
Every kubset must run on:
- `kind`
- a single machine
- without cloud dependencies

If it cannot be reproduced locally,
it does not belong in kubset-001.

---

### 5. Failure is a first-class scenario
Kubsets are not “happy path only”.

Design assumes:
- pods crash
- jobs fail
- nodes restart
- images are missing
- configs are wrong

Manifests should make failures:
- observable
- debuggable
- understandable

---

### 6. Safety before performance
Kubsets prefer:
- clarity over optimization
- correctness over cleverness
- predictability over speed

Production tuning is **explicitly out of scope**
for the core kubsets.

---

## Definition of Done (kubset-001)

A kubset is considered **complete** when:

- [ ] Namespace applies cleanly
- [ ] All manifests apply with `kubectl apply -f k8s/`
- [ ] Web deployment starts and serves traffic
- [ ] Database statefulset initializes correctly
- [ ] Services resolve via DNS
- [ ] DaemonSet runs on all nodes
- [ ] Job completes successfully
- [ ] CronJob runs on schedule
- [ ] Stack survives pod restarts
- [ ] Stack survives node restart (kind)

---

## What Kubsets Are NOT

Kubsets are **not**:
- production templates
- opinionated frameworks
- platform abstractions
- marketing examples

They are **learning instruments** and **engineering exercises**.

---

## Mental Model

Think of kubsets as:

> “Minimal satellites in low Earth orbit:  
> small, constrained, but fully functional.”

Every component must justify its mass, power, and existence.

---

## Next Steps

- kubset-002: Networking
- kubset-003: Storage
- kubset-004: Security
- kubset-005: Observability

Each future kubset builds on kubset-001,
but remains independently understandable.

---

**Kubsets reward patience, clarity, and discipline.**  
This mirrors real Kubernetes work more than any tutorial ever will.

