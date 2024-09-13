# Required files
PRETEST_REQUIRED_FILES = \
	$(TOP)/.env.project \
	$(TOP)/.env.docker \
	$(TOP)/.gitignore \
	$(TOP)/Dockerfile \
	$(TOP)/LICENSE \
	$(TOP)/README.md \
	$(TOP)/container_scripts/cmd_harness.sh \
	$(TOP)/container_scripts/cp_build.tmpl \
	$(TOP)/container_scripts/cp_pov \
	$(TOP)/container_scripts/cp_tests \
	$(TOP)/container_scripts/entrypoint.sh \
	$(TOP)/project.yaml \
	$(TOP)/run.sh

# Find missing files
PRETEST_MISSING_FILES = $(filter-out $(wildcard $(PRETEST_REQUIRED_FILES)),$(PRETEST_REQUIRED_FILES))

# Required Directories
PRETEST_REQUIRED_DIRS = \
	$(TOP)/container_scripts \
	$(TOP)/out \
	$(TOP)/src \
	$(TOP)/work

# Find missing directories
PRETEST_MISSING_DIRS = $(filter-out $(wildcard $(PRETEST_REQUIRED_DIRS)),$(PRETEST_REQUIRED_DIRS))

.PHONY: pretest

SHELL=/usr/bin/bash
# Check for required files and directories. This is only for validating repos during development.
pre-check:
	@if [[ -n "$(PRETEST_MISSING_FILES)" ]] || [[ -n "$(PRETEST_MISSING_DIRS)" ]]; then \
		[[ -n "$(PRETEST_MISSING_FILES)" ]] && echo "Missing required files: $(PRETEST_MISSING_FILES)" >&2; \
		[[ -n "$(PRETEST_MISSING_DIRS)" ]] && echo "Missing required directories: $(PRETEST_MISSING_DIRS)" >&2; \
		exit 1;	fi
