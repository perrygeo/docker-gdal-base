
SHELL = /bin/bash
TAG ?= latest

all: build

build:
	docker build --tag perrygeo/gdal-base:$(TAG) --file Dockerfile .
	docker tag perrygeo/gdal-base:$(TAG) perrygeo/gdal-base:latest

test: build
	# Test image inheritance and multistage builds
	cd tests && docker build -e TAG=$(TAG) --tag test-gdal-base-multistage --file Dockerfile.test .
	docker run --rm \
		--volume $(shell pwd)/:/app \
		test-gdal-base-multistage \
		/app/tests/run_multistage_tests.sh
	# Test GDAL CLI, etc on the base image itself
	docker run --rm \
		--volume $(shell pwd)/:/app \
		perrygeo/gdal-base:$(TAG) \
		/app/tests/run_tests.sh

shell: build
	docker run --rm -it \
		--volume $(shell pwd)/:/app \
		perrygeo/gdal-base:$(TAG) \
		/bin/bash
