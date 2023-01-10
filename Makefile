SHELL = bash

IO ?=

CYPRESS = docker compose run --rm cypress-browsers yarn run cypress
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

.PHONY: install
install: ## Install project dependencies.
ifeq ($(wildcard yarn.lock),)
	@echo "Install the Node modules according to package.json"
	@$(YARN) install
else
	@echo "Install the Node modules according to yarn.lock"
	@$(YARN) install --frozen-lockfile --check-files
endif

.PHONY: upgrade
upgrade: ## Upgrade project dependencies to their latest version (works only if project dependencies were already installed with "make install").
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
	@echo "| Check the typing |"
	@echo "|------------------|"
	@echo ""
	@make typecheck
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
	@$(YARN) prettier --check

.PHONY: fix-prettier
fix-prettier: ## Fix the code style.
	@$(YARN) prettier --write

.PHONY: typecheck
typecheck: ## Check the typing.
	@$(YARN) typecheck

.PHONY: eslint
eslint: ## Lint the TypeScript code.
ifeq ($(CI),true)
	@$(YARN) eslint
else
	@$(YARN) eslint
endif

.PHONY: cypress-open
cypress-open: ## Open the Cypress app.
	@$(CYPRESS) open

.PHONY: cypress-run
cypress-run: ## Run the Cypress end-to-end tests.
	@$(CYPRESS) run --headless ${IO}
