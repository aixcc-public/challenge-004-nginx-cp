# variables that control the CP repos
CP_SRC_DIR = $(TOP)/src
SRC_REPOS_RELATIVE_PATHS = $(shell yq -r '.cp_sources | keys | .[]' $(TOP)/project.yaml)
SRC_REPOS_MAKE_TARGETS = $(addprefix $(CP_SRC_DIR)/.pulled_, $(subst :,_colon_, $(subst /,_slash_, $(SRC_REPOS_RELATIVE_PATHS))))
SRC_REPOS_TARGET_DIRS = $(addprefix $(CP_SRC_DIR)/,$(SRC_REPOS_RELATIVE_PATHS))

# Check if any of the targets starts with "cpsrc-"
ifneq ($(filter cpsrc-%,$(MAKECMDGOALS)),)
$(warning Warning: invoking CP source-related targets MUST NOT occur during competition (only in development or pre-game).)
endif

.PHONY: cpsrc-prepare cpsrc-clean

$(CP_SRC_DIR)/.pulled_%: # Internal target to clone a source repo
	$(eval REVERT_CP_SRC_DIR_ESCAPE_STR=$(subst _colon_,:,$(subst _slash_,/,$*)))
	$(eval CP_ROOT_REPO_SUBDIR=$(@D)/$(REVERT_CP_SRC_DIR_ESCAPE_STR))
	@$(RM) -r $(CP_ROOT_REPO_SUBDIR)
	@mkdir -p $(CP_ROOT_REPO_SUBDIR)
	@yq -r '.cp_sources["$(REVERT_CP_SRC_DIR_ESCAPE_STR)"].address' $(TOP)/project.yaml | \
		xargs -I {} git clone {} $(CP_ROOT_REPO_SUBDIR)
	@yq -r '.cp_sources["$(REVERT_CP_SRC_DIR_ESCAPE_STR)"] | .ref // "main"' $(TOP)/project.yaml | \
		xargs -I {} sh -c \
			"git -C $(CP_ROOT_REPO_SUBDIR) fetch origin {}; \
			git -C $(CP_ROOT_REPO_SUBDIR) checkout --quiet {};"
	@touch $@

# Checkout CP source code repositories (for dev/pre-game only)
cpsrc-prepare: $(SRC_REPOS_MAKE_TARGETS)

# Remove CP source code repository artifacts (for dev/pre-game only)
cpsrc-clean:
	@$(RM) -r $(SRC_REPOS_MAKE_TARGETS)
	@$(RM) -r $(SRC_REPOS_TARGET_DIRS)
	@find $(CP_SRC_DIR)/* -type d -empty | xargs $(RM) -r
