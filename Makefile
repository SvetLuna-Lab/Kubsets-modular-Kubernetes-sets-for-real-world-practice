SHELL := /bin/bash

KIND_CLUSTER ?= kubsets
NAMESPACE    ?= kubsets

APP_NAME     ?= kubsets-web
APP_IMAGE    ?= kubsets-web:dev

K8S_DIR      ?= k8s
KIND_CFG     ?= kind/cluster.yaml

.PHONY: help kind-up kind-down kind-reset build load deploy delete restart status pods svc logs db port-forward smoke

help:
	@echo "kubsets Makefile"
	@echo ""
	@echo "Cluster:"
	@echo "  make kind-up        - create kind cluster"
	@echo "  make kind-down      - delete kind cluster"
	@echo "  make kind-reset     - delete + create cluster"
	@echo ""
	@echo "App image:"
	@echo "  make build          - build Docker image"
	@echo "  make load           - load image into kind"
	@echo ""
	@echo "Kubernetes:"
	@echo "  make deploy         - apply manifests"
	@echo "  make delete         - delete manifests"
	@echo "  make restart        - restart web deployment"
	@echo "  make status         - show status summary"
	@echo ""
	@echo "Debug:"
	@echo "  make pods           - list pods"
	@echo "  make svc            - list services"
	@echo "  make logs           - tail web logs"
	@echo "  make db             - tail postgres logs"
	@echo "  make port-forward   - forward web service to localhost:8080"
	@echo ""
	@echo "Checks:"
	@echo "  make smoke          - quick smoke check (pods + port-forward hint)"

kind-up:
	kind create cluster --name $(KIND_CLUSTER) --config $(KIND_CFG)
	@echo "Kind cluster '$(KIND_CLUSTER)' is up."

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)
	@echo "Kind cluster '$(KIND_CLUSTER)' deleted."

kind-reset: kind-down kind-up

build:
	docker build -t $(APP_IMAGE) ./app
	@echo "Built image: $(APP_IMAGE)"

load:
	kind load docker-image $(APP_IMAGE) --name $(KIND_CLUSTER)
	@echo "Loaded image into kind: $(APP_IMAGE)"

deploy:
	kubectl apply -f $(K8S_DIR)/00-namespace.yaml
	kubectl apply -n $(NAMESPACE) -f $(K8S_DIR)/05-configmap.yaml
	kubectl apply -n $(NAMESPACE) -f $(K8S_DIR)/20-statefulset-db.yaml
	kubectl apply -n $(NAMESPACE) -f $(K8S_DIR)/25-service-db.yaml
	kubectl apply -n $(NAMESPACE) -f $(K8S_DIR)/10-deployment-web.yaml
	kubectl apply -n $(NAMESPACE) -f $(K8S_DIR)/15-service-web.yaml
	kubectl apply -n $(NAMESPACE) -f $(K8S_DIR)/30-daemonset-agent.yaml
	kubectl apply -n $(NAMESPACE) -f $(K8S_DIR)/40-job-migrate.yaml
	kubectl apply -n $(NAMESPACE) -f $(K8S_DIR)/50-cronjob-heartbeat.yaml
	@echo "Deployed to namespace: $(NAMESPACE)"
	@echo "Tip: run 'make status'"

delete:
	- kubectl delete -n $(NAMESPACE) -f $(K8S_DIR)/50-cronjob-heartbeat.yaml
	- kubectl delete -n $(NAMESPACE) -f $(K8S_DIR)/40-job-migrate.yaml
	- kubectl delete -n $(NAMESPACE) -f $(K8S_DIR)/30-daemonset-agent.yaml
	- kubectl delete -n $(NAMESPACE) -f $(K8S_DIR)/15-service-web.yaml
	- kubectl delete -n $(NAMESPACE) -f $(K8S_DIR)/10-deployment-web.yaml
	- kubectl delete -n $(NAMESPACE) -f $(K8S_DIR)/25-service-db.yaml
	- kubectl delete -n $(NAMESPACE) -f $(K8S_DIR)/20-statefulset-db.yaml
	- kubectl delete -n $(NAMESPACE) -f $(K8S_DIR)/05-configmap.yaml
	- kubectl delete -f $(K8S_DIR)/00-namespace.yaml
	@echo "Deleted manifests."

restart:
	kubectl rollout restart deployment/$(APP_NAME) -n $(NAMESPACE)
	kubectl rollout status deployment/$(APP_NAME) -n $(NAMESPACE)

status:
	@echo "Context:"
	@kubectl config current-context
	@echo ""
	@echo "Namespace: $(NAMESPACE)"
	@kubectl get all -n $(NAMESPACE)
	@echo ""
	@echo "Pods:"
	@kubectl get pods -n $(NAMESPACE) -o wide

pods:
	kubectl get pods -n $(NAMESPACE) -o wide

svc:
	kubectl get svc -n $(NAMESPACE) -o wide

logs:
	kubectl logs -n $(NAMESPACE) deploy/$(APP_NAME) -f --tail=200

db:
	@echo "Finding postgres pod..."
	@POD=$$(kubectl get pods -n $(NAMESPACE) -l app=kubsets-db -o jsonpath='{.items[0].metadata.name}'); \
	echo "Pod: $$POD"; \
	kubectl logs -n $(NAMESPACE) $$POD -f --tail=200

port-forward:
	@echo "Port-forwarding service/kubsets-web to http://localhost:8080 ..."
	kubectl port-forward -n $(NAMESPACE) svc/kubsets-web 8080:80

smoke:
	@echo "Smoke check:"
	@kubectl get pods -n $(NAMESPACE)
	@echo ""
	@echo "If pods are Running, try:"
	@echo "  make port-forward"
	@echo "  curl -s http://localhost:8080/"
