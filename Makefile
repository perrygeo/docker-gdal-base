
SHELL = /bin/bash
TAG ?= latest

all: build

build:
	docker build --tag perrygeo/gdal-base:$(TAG) --file Dockerfile .

test: build
	# Test image inheritance and multistage builds
	cd tests && docker build --tag test-gdal-base-multistage --file Dockerfile.test .
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
	docker run \
		--volume $(shell pwd)/:/app \
		--rm -it --tty \
		perrygeo/gdal-base:$(TAG) \
		/bin/bash
