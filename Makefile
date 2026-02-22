.PHONY: test sync

FEATURE_PROJECT_FOLDER := devcontainer-feature
FEATURE_NAME := ubuntu-dotfiles
BASE_IMAGES := ubuntu:latest ubuntu:22.04

sync:
	tar -czf $(FEATURE_PROJECT_FOLDER)/src/$(FEATURE_NAME)/dotfiles.tar.gz \
		--exclude='./devcontainer-feature' \
		--exclude='./.git' \
		-C . .

test: sync
	$(foreach image,$(BASE_IMAGES), \
		npx @devcontainers/cli features test \
			--project-folder $(FEATURE_PROJECT_FOLDER) \
			--features $(FEATURE_NAME) \
			--base-image $(image);)
