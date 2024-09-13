ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
TOP:=$(ROOT_DIR)
export TOP

# Check for required executables (dependencies)
__UNUSED_REQUIRED_EXE = git yq docker
__UNUSED_EVAL_EXES := $(foreach exe,$(__UNUSED_REQUIRED_EXE), \
	$(if $(shell command -v $(exe)),,$(warning Required executable not in PATH: $(exe))))

# Check for required file that will error out elsewhere if not present
ifeq (,$(wildcard $(ROOT_DIR)/project.yaml))
$(error Required file not found: $(ROOT_DIR)/project.yaml)
endif

# Check yq version
__UNUSED_YQ_REQUIRED_MAJOR_VERSION ?= 4
__UNUSED_YQ_ACTUAL_MAJOR_VERSION = $(shell yq --version | grep -o "version v.*" | grep -Eo '[0-9]+(\.[0-9]+)+' | cut -f1 -d'.')
ifneq ($(__UNUSED_YQ_REQUIRED_MAJOR_VERSION),$(__UNUSED_YQ_ACTUAL_MAJOR_VERSION))
$(error Unexpected major version of 'yq'. Expected: $(__UNUSED_YQ_REQUIRED_MAJOR_VERSION), Actual: $(__UNUSED_YQ_ACTUAL_MAJOR_VERSION)))
endif

# include other make utilities and targets
include $(ROOT_DIR)/includes/pretest.mk
include $(ROOT_DIR)/includes/cpsrc.mk
include $(ROOT_DIR)/includes/docker.mk

.PHONY: help
.DEFAULT_GOAL := help

# Show all Makefile targets
help:
	@awk '/^#/{c=substr($$0,3);next}c&&/^[[:alpha:]][[:alnum:]_-]+:/{print substr($$1,1,index($$1,":")),c}1{c=0}' $(MAKEFILE_LIST) | column -s: -t
