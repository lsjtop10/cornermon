.PHONY: build run test clean docker-build swag

build:
	$(MAKE) -C backend build

run:
	$(MAKE) -C backend run

test:
	$(MAKE) -C backend test

clean:
	$(MAKE) -C backend clean

docker-build:
	$(MAKE) -C backend docker-build

swag:
	$(MAKE) -C backend swag
