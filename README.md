# kubsets — Kubernetes “sets” in practice

A hands-on repo of small, composable Kubernetes building blocks (“kubsets”):
Namespace, ConfigMap, Deployment, Service, StatefulSet, DaemonSet, Job, CronJob — with a local Kind cluster for fast iteration.

## Goals
- Practice real K8s primitives in isolated, testable slices
- Make changes observable (logs, health endpoints, DB readiness)
- Keep everything reproducible with a single Makefile

## Quickstart (Kind)
```bash
make kind-up
make build
make deploy
make status
make logs
```

## Endpoints

- Web service exposes /health and /env

- CronJob posts a “heartbeat” log line periodically

## Clean up

make clean
make kind-down

## Notes

- This repo is intentionally minimal: no external ingress controller required.

- Database is a Postgres StatefulSet with a PVC (hostPath/standard Kind storage behavior).








