SHELL := /bin/bash

run:
	go run main.go

# Building containers

VERSION := 1.0

all: third

third:
	docker build \
		-f zarf/docker/Dockerfile \
		-t third-amd64:$(VERSION) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.
