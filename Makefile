SHELL = bash

IO ?=

CYPRESS = docker compose run --rm cypress-browsers yarn run cypress
YARN = docker compose run --rm --service-ports node yarn

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
	@docker compose up -d node
	@echo ""
	@echo "┌─────────────────────────────────────────────────┐"
	@echo "│                                                 │"
	@echo "│   ◈ Server now ready on http://localhost:3000   │"
	@echo "│                                                 │"
	@echo "└─────────────────────────────────────────────────┘"
	@echo ""

.PHONY: build
build: node_modules ## Build the production artifacts.
	@$(YARN) build

.PHONY: prod
prod: #main# Preview the production build. Be sure to first run "make install".
	@docker compose up -d prod
	@echo ""
	@echo "┌─────────────────────────────────────────────────┐"
	@echo "│                                                 │"
	@echo "│   ◈ Server now ready on http://localhost:8000   │"
	@echo "│                                                 │"
	@echo "└─────────────────────────────────────────────────┘"
	@echo ""

.PHONY: down
down: #main# Stop the application (dev or prod preview alike).
	@docker compose down -v --remove-orphans

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
	@make prettier
	@echo ""
	@echo "|------------------|"
	@echo "| Lint the TS code |"
	@echo "|------------------|"
	@echo ""
	@make eslint
	@echo ""
	@echo "|----------------------|"
	@echo "| Run end-to-end tests |"
	@echo "|----------------------|"
	@echo ""
	@make dev
	@make cypress-run
	@echo ""
	@echo "All tests successful. You can run \"make down\" to stop the application."

.PHONY: stylelint
stylelint: ## Lint the CSS code.
ifeq ($(CI),true)
	@$(YARN) stylelint
else
	@$(YARN) stylelint
endif

.PHONY: prettier
prettier: ## Check the code style.
ifeq ($(CI),true)
	@$(YARN) prettier --check
else
	@$(YARN) prettier --check
endif

.PHONY: fix-prettier
fix-prettier: ## Fix the code style.
	@$(YARN) prettier --write

.PHONY: eslint
eslint: ## Lint the TypeScript code.
ifeq ($(CI),true)
	@$(YARN) eslint
else
	@$(YARN) eslint
endif

.PHONY: cypress-open
cypress-open: ## Open the Cypress app
	@$(CYPRESS) open

.PHONY: cypress-run
cypress-run: ## Run the Cypress end-to-end tests
ifeq ($(CI),true)
	@$(CYPRESS) run --headless --record --key ${CYPRESS_RECORD_KEY}
else
	@$(CYPRESS) run ${IO}
endif
