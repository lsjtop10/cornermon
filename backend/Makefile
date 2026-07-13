.PHONY: build run test clean docker-build swag

# Local Environment Setup
# Load .env file if it exists
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

build:
	go build -o bin/server cmd/server/main.go

run: build
	./bin/server

test:
	go test -v ./...

clean:
	rm -rf bin

docker-build:
	docker build -t cornermon-backend -f Dockerfile .

swag:
	swag init -g internal/infrastructure/web/doc.go -d . -o ../api --parseDependency --parseInternal
