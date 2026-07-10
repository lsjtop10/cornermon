.PHONY: build run test clean docker-build
	
# Local Environment Setup
# Load .env file if it exists
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

build:
	cd backend && go build -o bin/server cmd/server/main.go

run: build
	./backend/bin/server

test:
	cd backend && go test -v ./...

clean:
	rm -rf backend/bin

docker-build:
	docker build -t cornermon-backend -f backend/Dockerfile backend/

swag:
	cd backend && swag init -g internal/infrastructure/web/doc.go -d . --parseDependency --parseInternal
