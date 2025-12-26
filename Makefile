NAMESPACE := kubsets
KIND_CLUSTER := kubsets
IMG := kubsets-web:local

.PHONY: kind-up kind-down build load deploy clean status logs port-forward

kind-up:
	kind create cluster --name $(KIND_CLUSTER) --config kind/cluster.yaml

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)

build:
	docker build -t $(IMG) ./app

load:
	kind load docker-image $(IMG) --name $(KIND_CLUSTER)

deploy:
	kubectl apply -f k8s/00-namespace.yaml
	kubectl apply -f k8s/05-configmap.yaml
	kubectl apply -f k8s/25-service-db.yaml
	kubectl apply -f k8s/20-statefulset-db.yaml
	kubectl apply -f k8s/40-job-migrate.yaml
	kubectl apply -f k8s/30-daemonset-agent.yaml
	kubectl apply -f k8s/10-deployment-web.yaml
	kubectl apply -f k8s/15-service-web.yaml
	kubectl apply -f k8s/50-cronjob-heartbeat.yaml

clean:
	kubectl delete namespace $(NAMESPACE) --ignore-not-found=true

status:
	kubectl get all -n $(NAMESPACE)

logs:
	kubectl logs -n $(NAMESPACE) deploy/web --tail=100

port-forward:
	kubectl -n $(NAMESPACE) port-forward svc/web 8080:80
