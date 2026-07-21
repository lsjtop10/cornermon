.PHONY: build run test clean docker-build swag cleanup-corners start-postgres reset-postgres stop-postgres

MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
POSTGRES_COMPOSE_FILE := $(MAKEFILE_DIR)db/docker-compose.yml

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

cleanup-corners:
	go run ./cmd/cleanup-corners

start-postgres:
	docker compose --file "$(POSTGRES_COMPOSE_FILE)" up

reset-postgres:
	docker compose --file "$(POSTGRES_COMPOSE_FILE)" down -v
	docker compose --file "$(POSTGRES_COMPOSE_FILE)"  up --build 


stop-postgres:
	docker compose --file "$(POSTGRES_COMPOSE_FILE)" down
