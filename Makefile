SHELL = bash

ifeq ($(CI),true)
	YARN = yarn
else
	YARN = docker compose run --rm --service-ports node yarn
endif

.PHONY: help
help:
	@echo "-----------------"
	@echo "- Main commands -"
	@echo "-----------------"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?#main# .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?#main# "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "----------------------"
	@echo "- Secondary commands -"
	@echo "----------------------"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

# Application dependencies

yarn.lock: package.json
	@$(YARN) install

node_modules: yarn.lock
	@$(YARN) install --frozen-lockfile --check-files

.PHONY: install
install: node_modules ## Install project dependencies.

.PHONY: update
update: ## Updates project dependencies to their latest version (works only if project dependencies were already installed).
	@$(YARN) upgrade-interactive --latest
	@$(YARN) upgrade

# Serve and build-prod

.PHONY: dev
dev: node_modules #main# Run the application using ViteJS dev server.
	@$(YARN) dev

.PHONY: build
build: node_modules #main# Build the production artifacts.
	@$(YARN) build

.PHONY: start
start: node_modules #main# Preview the production build.
	@$(YARN) start

# Tests

.PHONY: tests
tests: node_modules #main# Execute all the tests.
	@echo ""
	@echo "|----------------------|"
	@echo "| Lint the stylesheets |"
	@echo "|----------------------|"
	@echo ""
	@make stylelint
	@echo ""
	@echo "|----------------------|"
	@echo "| Check the code style |"
	@echo "|----------------------|"
	@echo ""
	@make prettier CI=true
	@echo ""
	@echo "|------------------|"
	@echo "| Lint the TS code |"
	@echo "|------------------|"
	@echo ""
	@make eslint

.PHONY: stylelint
stylelint: ## Lint the CSS code.
	@$(YARN) stylelint

.PHONY: prettier
prettier: ## Check the code style. Only warn when run on the CI, apply the needed changes when run locally.
ifeq ($(CI),true)
	@$(YARN) prettier --check
else
	@$(YARN) prettier --write
endif

.PHONY: eslint
eslint: ## Lint the TypeScript code.
	@$(YARN) eslint
