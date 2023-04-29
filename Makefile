SHELL = bash

IO ?=

YARN_CYPRESS = docker compose run --rm cypress-browsers yarn
YARN = docker compose run --rm node yarn

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

~/.yarnrc:
	touch ~/.yarnrc

~/.config/yarn:
	mkdir -p ~/.config/yarn

~/.cache/yarn:
	mkdir -p ~/.cache/yarn

~/.cache/Cypress:
	mkdir -p ~/.cache/Cypress

.PHONY: yarn-config-and-cache
yarn-config-and-cache: ~/.yarnrc ~/.config/yarn ~/.cache/yarn ~/.cache/Cypress

.PHONY: pull
pull: ## Pull all Docker images.
	docker compose pull

.PHONY: install
install: yarn-config-and-cache ## Install project dependencies.
ifeq ($(wildcard yarn.lock),)
	@echo "Install the Node modules according to package.json"
	@$(YARN) install
else
	@echo "Install the Node modules according to yarn.lock"
	@$(YARN) install --frozen-lockfile --check-files
endif

.PHONY: cypress-install
cypress-install: yarn-config-and-cache ## Install Cypress binary.
	@$(YARN) cypress install

.PHONY: upgrade
upgrade: yarn-config-and-cache ## Upgrade project dependencies to their latest version (works only if project dependencies were already installed with "make install").
	@$(YARN) upgrade
	@$(YARN) upgrade-interactive --latest
	@$(YARN) upgrade

# Run the application

.PHONY: database
database: ## Start the database
	@docker compose up -d database

.PHONY: create-migration
create-migration: ## Create an SQL migration script. Use as follows: "make create-migration IO='my migration name'".
	@$(YARN) run migrate create ${IO}

.PHONY: migrate
migrate: install ## Run the SQL migration scriptss.
	@$(YARN) run migrate up

.PHONY: build
build: install ## Build the production artifacts.
	@$(YARN) build

.PHONY: dev
dev: install database #main# Run the application using ViteJS dev server.
	@make migrate
	@docker compose up -d dev
	@echo ""
	@echo "┌────────────────────────────────────────────--─────┐"
	@echo "│                                                   │"
	@echo "│   ◈ Server now ready on http://localhost:3000 ◈   │"
	@echo "│                                                   │"
	@echo "└─────────────────────────────────────────────--────┘"
	@echo ""


.PHONY: prod
prod: install database #main# Preview the production build. Be sure to first run "make install".
	@make migrate
	@docker compose up -d prod
	@echo ""
	@echo "┌─────────────────────────────────────────────--────┐"
	@echo "│                                                   │"
	@echo "│   ◈ Server now ready on http://localhost:8000 ◈   │"
	@echo "│                                                   │"
	@echo "└─────────────────────────────────────────────--────┘"
	@echo ""

.PHONY: down
down: #main# Stop the application (dev or prod preview alike).
	@docker compose down -v --remove-orphans

# Tests

.PHONY: tests
tests: install #main# Execute all the tests.
	@echo ""
	@echo "|-----------------------|"
	@echo "| Check the code format |"
	@echo "|-----------------------|"
	@echo ""
	@make check-format
	@echo ""
	@echo ""
	@echo "|----------------------|"
	@echo "| Lint the stylesheets |"
	@echo "|----------------------|"
	@echo ""
	@make lint-css
	@echo "|-------------------|"
	@echo "| Lint the app code |"
	@echo "|-------------------|"
	@echo ""
	@make lint-js
	@echo ""
	@echo "|------------------|"
	@echo "| Check the typing |"
	@echo "|------------------|"
	@echo ""
	@make typecheck
	@echo ""
	@echo "|----------------|"
	@echo "| Run unit tests |"
	@echo "|----------------|"
	@echo ""
	@make unit-tests CI=true
	@echo ""
	@echo "|---------------------|"
	@echo "| Run component tests |"
	@echo "|---------------------|"
	@echo ""
	@make component-tests CI=true
	@echo ""
	@echo "|----------------------|"
	@echo "| Run end-to-end tests |"
	@echo "|----------------------|"
	@echo ""
	@make database
	@make migrate
	@make e2e-tests CI=true
	@echo ""
	@echo "All tests successful. You can run \"make down\" to stop the application."

.PHONY: check-format
check-format: ## Check the code format.
	@$(YARN) prettier --check

.PHONY: fix-format
fix-format: ## Fix the code format.
	@$(YARN) prettier --write

.PHONY: lint-css
lint-css: ## Lint the CSS code.
	@$(YARN) lint:css

.PHONY: fix-css
fix-css: ## Fix the CSS code style.
	@$(YARN) lint:css --fix

.PHONY: lint-js
lint-js: ## Lint the TypeScript code.
	@$(YARN) lint:js

.PHONY: fix-js
fix-js: ## Fix the TypeScript code.
	@$(YARN) lint:js --fix

.PHONY: typecheck
typecheck: ## Check the typing.
	@$(YARN) typecheck

.PHONY: unit-tests
unit-tests: ## Check the typing.
ifeq ($(CI),true)
	@$(YARN) unit:ci ${IO}
else
	@$(YARN) unit:watch
endif

.PHONY: component-tests
component-tests: ## Run the Cypress end-to-end tests.
ifeq ($(CI),true)
	@$(YARN_CYPRESS) component:headless ${IO}
else
	@$(YARN_CYPRESS) component
endif

.PHONY: e2e-tests
e2e-tests: ## Open the Cypress app.
ifeq ($(CI),true)
	@$(YARN_CYPRESS) e2e:headless ${IO}
else
	@$(YARN_CYPRESS) e2e
endif
