TAG := bdk-reserves
TAG_57 := bdk-reserves-57
TAG_63 := bdk-reserves-61
http_proxy ?= http://172.17.0.1:3128
DOCKER_RUN := docker run --interactive --rm \
	-v ${PWD}:/home/satoshi \

build: builder
	$(DOCKER_RUN) --tty ${TAG} cargo build

test: test_current test_63

test_current: builder
	rm -f Cargo.lock
	$(DOCKER_RUN) ${TAG} cargo test

test_63: builder_63
	rm -f Cargo.lock
	$(DOCKER_RUN) ${TAG_63} cargo test || true
	$(DOCKER_RUN) ${TAG_63} cargo update -p home:0.5.11 --precise 0.5.5 || true
	$(DOCKER_RUN) ${TAG_63} cargo update -p tokio:1.43.0 --precise 1.38.1 || true
	$(DOCKER_RUN) ${TAG_63} cargo update -p cc --precise 1.0.105 || true
	$(DOCKER_RUN) ${TAG_63} cargo test

run: builder
	$(DOCKER_RUN) --tty ${TAG} cargo run

wasm-unknown: builder
	$(DOCKER_RUN) --tty ${TAG} cargo check --target wasm32-unknown-unknown --no-default-features

wasm-wasi: builder
	$(DOCKER_RUN) --tty ${TAG} cargo check --target wasm32-wasi --no-default-features

wasm-emscripten: builder
	$(DOCKER_RUN) --tty ${TAG} cargo check --target wasm32-unknown-emscripten --no-default-features

sh: builder
	$(DOCKER_RUN) --tty ${TAG} sh

builder:
	docker build --tag ${TAG} \
		--build-arg http_proxy="${http_proxy}" \
		--build-arg UID="$(shell id -u)" \
		.

builder_57:
	docker build --tag ${TAG_57}\
		--build-arg http_proxy="${http_proxy}" \
		--build-arg UID="$(shell id -u)" \
		-f Dockerfile_57 \
		.

builder_63:
	docker build --tag ${TAG_63}\
		--build-arg http_proxy="${http_proxy}" \
		--build-arg UID="$(shell id -u)" \
		-f Dockerfile_63 \
		.

