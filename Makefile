# Project
PROJECT?=fulldrone
ORGANIZATION?=czertbytes
REPOSITORY?=github.com
DOCKER_SOURCE?=Docker

# Git
GITHASH?=$(shell git rev-parse --short HEAD)

# Build
BUILDER_IMAGE?=czertbytes/golang-builder:latest
GO_BUILD_PARAMS?=-a -installsuffix -cgo
GO_BUILD_CMD?=go build $(GO_BUILD_PARAMS) -o $(DOCKER_SOURCE)/bin/$(PROJECT) main.go

# Build Linux
GO_BUILD_LINUX_PARAMS?=-a -installsuffix -cgo -ldflags "-extldflags '-static'"
GO_BUILD_LINUX_CMD?=go build $(GO_BUILD_LINUX_PARAMS) -o $(DOCKER_SOURCE)/bin/$(PROJECT)-linux main.go

BUILD_TAGS?=latest $(GITHASH)

# Project go deps
GO_DEPS?=golang.org/x/tools/cmd/cover golang.org/x/tools/cmd/vet golang.org/x/net/context github.com/mattn/go-sqlite3

# Test packages
# ignores "can't load package: package" errors produced by go list command
GO_TEST_PACKAGES?=$(shell go list ./... 2>/dev/null | grep -v /vendor/)

all: test image

deps:
	for dep in $(GO_DEPS); do \
		go get -u $$dep ; \
	done

vendor:
	rm -rf vendor/
	for dep in $(GO_DEPS); do \
		mkdir -p vendor/$$dep ; \
		cp -R $(GOPATH)src/$$dep/ vendor/$$dep ; \
	done

build:
	mkdir -p $(DOCKER_SOURCE)/bin
	$(GO_BUILD_CMD)

build-linux:
	mkdir -p $(DOCKER_SOURCE)/bin
	docker run --rm \
		-v $(PWD):/go/src/$(REPOSITORY)/$(ORGANIZATION)/$(PROJECT) \
		-w /go/src/$(REPOSITORY)/$(ORGANIZATION)/$(PROJECT) \
		-e GOOS=linux \
		-e GOARCH=amd64 \
		-e CGO_ENABLED=1 \
		$(BUILDER_IMAGE) \
		$(GO_BUILD_LINUX_CMD)

test:
	go test -v -timeout 60s $(GO_TEST_PACKAGES)

image: build-linux
	for tag in $(BUILD_TAGS); do \
		docker build -t $(ORGANIZATION)/$(PROJECT):$$tag $(DOCKER_SOURCE) ;  \
	done

run:
	docker-compose up

clean:
	rm -rf $(DOCKER_SOURCE)/bin

.PHONY: all
