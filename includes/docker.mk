# variables that impact the docker build target (these can be overriden)
DOCKER_BUILD_ARGS ?=
DOCKER_IMAGE_NAME ?= $(shell yq  -r '.docker_image' $(TOP)/project.yaml | xargs basename | cut -f1 -d":")
CP_DOCKER_IMAGE ?= $(shell yq  -r '.docker_image' $(TOP)/project.yaml)

# Check if any of the targets starts with "docker-"
ifneq ($(filter docker-%,$(MAKECMDGOALS)),)
$(warning Warning: invoking Docker-related targets MUST NOT occur during competition (only in development or pre-game).)
endif

.PHONY: docker-build docker-config-local docker-pull docker-clean

# Build the repo's docker container (for dev/pre-game only)
docker-build: cpsrc-prepare
	@docker build $(DOCKER_BUILD_ARGS) -t $(DOCKER_IMAGE_NAME) -f $(TOP)/Dockerfile $(TOP)

# Set the target docker container in run.sh to DOCKER_IMAGE_NAME (for dev/pre-game only)
docker-config-local:
	sed -i -e '$$aDOCKER_IMAGE_NAME=$(DOCKER_IMAGE_NAME)' $(TOP)/.env.project

# Pull the docker container image specified in the project.yaml file (for dev/pre-game only)
docker-pull:
	@docker pull $(CP_DOCKER_IMAGE)

# Remove the CP's built docker container (for dev/pre-game only)
docker-clean:
	@if docker inspect $(DOCKER_IMAGE_NAME) >/dev/null 2>&1; then docker rmi $(DOCKER_IMAGE_NAME); fi
	sed -i "/^DOCKER_IMAGE_NAME=.*$$/d" $(TOP)/.env.project
