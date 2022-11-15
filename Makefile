export IMG_NAME          := jeewangue/crd-json-schema-server
export IMG_REGISTRY      := docker.io
export DOCKER_BUILDKIT   := 1

.DEFAULT_GOAL := help

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: build-docker
build-docker: ## build docker
	./scripts/build-docker.sh

.PHONY: push-docker
push-docker: ## push docker
	./scripts/push-docker.sh

