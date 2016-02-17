.PHONY: vendor

PACKAGES = $(shell go list ./... | grep -v /vendor/)

all: gen build

deps:
	go get -u golang.org/x/tools/cmd/cover
	go get -u golang.org/x/tools/cmd/vet
	go get -u golang.org/x/net/context

build:
	mkdir -p bin
	go build -a -installsuffix cgo -o bin/fulldrone main.go

test:
	go test -cover $(PACKAGES)

vendor:
	vexp
