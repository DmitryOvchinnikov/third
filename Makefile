SHELL := /bin/bash

# Testing running system

# For testing a simple query on the system. Don't forget to `make seed` first.
# curl --user "sales-admin@example.com:gophers" http://localhost:3000/v1/users/token
# export TOKEN="COPY TOKEN STRING FROM LAST CALL"
# curl -H "Authorization: Bearer ${TOKEN}" http://localhost:3000/v1/users/1/2
#
# For testing load on the service.
# go install github.com/rakyll/hey@latest
# hey -m GET -c 100 -n 10000 -H "Authorization: Bearer ${TOKEN}" http://localhost:3000/v1/users/1/2
#
# Access metrics directly (4000) or through the sidecar (3001)
# go install github.com/divan/expvarmon@latest
# expvarmon -ports=":4000" -vars="build,requests,goroutines,errors,panics,mem:memstats.Alloc"
# expvarmon -ports=":3001" -endpoint="/metrics" -vars="build,requests,goroutines,errors,panics,mem:memstats.Alloc"
#
# To generate a private/public key PEM file.
# openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:2048
# openssl rsa -pubout -in private.pem -out public.pem
# ./sales-admin genkey
#
# Testing coverage.
# go test -coverprofile p.out
# go tool cover -html p.out
#
# Test debug endpoints.
# curl http://localhost:4000/debug/liveness
# curl http://localhost:4000/debug/readiness
#
# Running pgcli client for database.
# pgcli postgresql://postgres:postgres@localhost
#
# Launch zipkin.
# http://localhost:9411/zipkin/


run:
	go run ./app/services/sales-api/main.go | go run ./app/tooling/logfmt/main.go

admin:
	go run ./app/tooling/sales-admin/main.go


# Building containers

VERSION := 1.0

all: sales-api

sales-api:
	docker build \
		-f zarf/docker/sales-api/Dockerfile \
		-t sales-api-amd64:$(VERSION) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.

# Running from within k8s/kind

KIND_CLUSTER := sales-cluster

kind-up:
	kind create cluster \
		--image kindest/node:v1.23.0@sha256:49824ab1727c04e56a21a5d8372a402fcd32ea51ac96a2706a12af38934f81ac \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/kind/kind-config.yaml
	kubectl config set-context --current --namespace=sales-system

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)

kind-load:
	cd zarf/k8s/kind/sales-pod; kustomize edit set image sales-api-image=sales-api-amd64:$(VERSION)
	kind load docker-image sales-api-amd64:$(VERSION) --name $(KIND_CLUSTER)

kind-apply:
	kustomize build zarf/k8s/kind/sales-pod | kubectl apply -f -

kind-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
	kubectl get pods -o wide --watch --all-namespaces

kind-status-sales:
	kubectl get pods -o wide --watch

kind-logs:
	kubectl logs -l app=sales --all-containers=true -f --tail=100 | go run ./app/tooling/logfmt/main.go

kind-restart:
	kubectl rollout restart deployment sales-pod

kind-update: all kind-load kind-restart

kind-update-apply: all kind-load kind-apply

kind-describe:
	kubectl describe pod -l app=sales


# Running tests within the local computer

test:
	go test ./... -count=1
	staticcheck -checks=all ./...


# Module support

tidy:
	go mod tidy -compat=1.17
	go mod vendor

update:
	go get -u -t -d -v ./...



