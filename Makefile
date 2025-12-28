# Makefile (replace полностью)
# kubsets — “Kubernetes sets” on practice (Kind + manifests)

SHELL := /bin/bash

KIND_CLUSTER ?= kubsets
NAMESPACE    ?= kubsets

KUBECTL ?= kubectl
KIND   ?= kind

K8S_DIR ?= k8s

.PHONY: help

help:
	@echo "Targets:"
	@echo "  make kind-up            Create local Kind cluster ($(KIND_CLUSTER))"
	@echo "  make kind-down          Delete Kind cluster ($(KIND_CLUSTER))"
	@echo "  make deploy             Apply namespace + all manifests"
	@echo "  make destroy            Delete namespace (and everything inside)"
	@echo "  make status             Show status in namespace $(NAMESPACE)"
	@echo "  make logs-web           Tail logs from web deployment"
	@echo "  make logs-agent         Tail logs from node agent daemonset"
	@echo "  make logs-migrate       Show logs from migrate job (if exists)"
	@echo "  make cron-jobs          Show cronjobs and jobs (heartbeat)"
	@echo "  make pf-web             Port-forward web service to localhost:8080"
	@echo "  make smoke              Minimal smoke check (wait for readiness)"
	@echo "  make showcase           2-minute demo output (what to show on screen)"
	@echo "  make clean              Delete completed jobs (safe local cleanup)"

kind-up:
	$(KIND) create cluster --name $(KIND_CLUSTER) --config kind/cluster.yaml
	@echo "Kind cluster '$(KIND_CLUSTER)' is up."

kind-down:
	$(KIND) delete cluster --name $(KIND_CLUSTER)

deploy:
	$(KUBECTL) apply -f $(K8S_DIR)/00-namespace.yaml
	$(KUBECTL) apply -n $(NAMESPACE) -f $(K8S_DIR)/05-configmap.yaml
	$(KUBECTL) apply -n $(NAMESPACE) -f $(K8S_DIR)/10-deployment-web.yaml
	$(KUBECTL) apply -n $(NAMESPACE) -f $(K8S_DIR)/15-service-web.yaml
	$(KUBECTL) apply -n $(NAMESPACE) -f $(K8S_DIR)/20-statefulset-db.yaml
	$(KUBECTL) apply -n $(NAMESPACE) -f $(K8S_DIR)/25-service-db.yaml
	$(KUBECTL) apply -n $(NAMESPACE) -f $(K8S_DIR)/30-daemonset-agent.yaml
	$(KUBECTL) apply -n $(NAMESPACE) -f $(K8S_DIR)/40-job-migrate.yaml
	$(KUBECTL) apply -n $(NAMESPACE) -f $(K8S_DIR)/50-cronjob-heartbeat.yaml

destroy:
	-$(KUBECTL) delete namespace $(NAMESPACE) --ignore-not-found=true

status:
	@echo "== Namespace =="
	$(KUBECTL) get ns $(NAMESPACE) || true
	@echo
	@echo "== Workloads =="
	$(KUBECTL) get deploy,sts,ds,job,cronjob -n $(NAMESPACE) -o wide || true
	@echo
	@echo "== Pods =="
	$(KUBECTL) get pods -n $(NAMESPACE) -o wide || true
	@echo
	@echo "== Services =="
	$(KUBECTL) get svc -n $(NAMESPACE) -o wide || true
	@echo
	@echo "== Events (tail) =="
	$(KUBECTL) get events -n $(NAMESPACE) --sort-by=.lastTimestamp | tail -n 20 || true

logs-web:
	$(KUBECTL) logs -n $(NAMESPACE) deploy/web --tail=200 -f

logs-agent:
	$(KUBECTL) logs -n $(NAMESPACE) ds/node-agent --tail=200 -f

logs-migrate:
	@# job name is expected to be "migrate"
	$(KUBECTL) logs -n $(NAMESPACE) job/migrate --tail=200 || true

cron-jobs:
	@echo "== CronJobs =="
	$(KUBECTL) get cronjob -n $(NAMESPACE) -o wide || true
	@echo
	@echo "== Jobs (sorted by time) =="
	$(KUBECTL) get jobs -n $(NAMESPACE) --sort-by=.metadata.creationTimestamp || true

pf-web:
	@echo "Port-forward: http://localhost:8080"
	$(KUBECTL) port-forward -n $(NAMESPACE) svc/web 8080:80

smoke:
	@echo "== Smoke check: wait for platform readiness =="
	@echo "[1/4] wait: web deployment Available"
	$(KUBECTL) wait -n $(NAMESPACE) --for=condition=available deploy/web --timeout=120s
	@echo "[2/4] wait: postgres statefulset Ready"
	$(KUBECTL) rollout status -n $(NAMESPACE) sts/postgres --timeout=180s
	@echo "[3/4] wait: migrate job Complete"
	$(KUBECTL) wait -n $(NAMESPACE) --for=condition=complete job/migrate --timeout=180s
	@echo "[4/4] check: heartbeat cronjob exists"
	$(KUBECTL) get cronjob/heartbeat -n $(NAMESPACE)
	@echo
	@echo "Smoke check OK."

showcase:
	@echo "== kubsets: 2-minute demo output =="
	@echo
	@echo "1) Current state"
	$(KUBECTL) get all -n $(NAMESPACE) -o wide || true
	@echo
	@echo "2) Web logs (tail)"
	-$(KUBECTL) logs -n $(NAMESPACE) deploy/web --tail=20 || true
	@echo
	@echo "3) Migrate job status + logs (tail)"
	-$(KUBECTL) get job/migrate -n $(NAMESPACE) -o wide || true
	-$(KUBECTL) logs -n $(NAMESPACE) job/migrate --tail=20 || true
	@echo
	@echo "4) Heartbeat CronJob + recent Jobs"
	-$(KUBECTL) get cronjob/heartbeat -n $(NAMESPACE) -o wide || true
	-$(KUBECTL) get jobs -n $(NAMESPACE) --sort-by=.metadata.creationTimestamp | tail -n 10 || true
	@echo
	@echo "Tip: take a screenshot of 'kubectl get all -n $(NAMESPACE)' for README."

clean:
	@echo "Deleting completed jobs in $(NAMESPACE)..."
	-$(KUBECTL) delete job -n $(NAMESPACE) --field-selector status.successful=1 --ignore-not-found=true
