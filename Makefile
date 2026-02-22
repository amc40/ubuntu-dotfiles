.PHONY: test

FEATURE_PROJECT_FOLDER := devcontainer-feature
FEATURE_NAME := ubuntu-dotfiles
BASE_IMAGES := ubuntu:latest ubuntu:22.04

test:
	$(foreach image,$(BASE_IMAGES), \
		npx @devcontainers/cli features test \
			--project-folder $(FEATURE_PROJECT_FOLDER) \
			--features $(FEATURE_NAME) \
			--base-image $(image);)
