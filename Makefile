SHELL = bash

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

# Environment Variables

APP_ENV ?= dev
IO ?=
L ?= max
TL ?= max

PHPMD_OUTPUT=ansi
PHPMD_RULESETS=cleancode,codesize,controversial,design,naming,unusedcode

ifeq ($(CI),true)
	DC_RUN = docker-compose run --rm -T
else
	DC_RUN = docker-compose run --rm
endif

# Build Docker images

.PHONY: pull
pull: ## Pull all Docker images used in docker-compose.yaml.
	@docker-compose pull --ignore-pull-failures

.PHONY: build
build: ## Build all Docker images at once (back-end and front-end, development and production).
	@docker-compose build --parallel

.PHONY: build-dev
build-dev: ## Build development image (carcel/wishlist/dev:php).
	@docker-compose build php

.PHONY: build-prod
build-prod: ## Build production images (carcel/wishlist/fpm and carcel/wishlist/nginx).
	@docker-compose build --parallel nginx fpm

.PHONY: up
up: ## Start all services defined docker-compose.yaml.
	@docker-compose up -d --remove-orphans ${IO}

# Prepare the application dependencies

.PHONY: install-back-end-dependencies
install-back-end-dependencies: build-dev ## Install back-end dependencies.
	@$(DC_RUN) php composer install --prefer-dist --optimize-autoloader --no-interaction

.PHONY: install-front-end-dependencies
install-front-end-dependencies: ## Install front-end dependencies.
ifeq ($(wildcard yarn.lock),)
	@echo "Install the Node modules according to package.json"
	@$(DC_RUN) node yarn install
endif
	@echo "Install the Node modules according to yarn.lock"
	@$(DC_RUN) node yarn install --frozen-lockfile --check-files

.PHONY: dependencies
dependencies: install-back-end-dependencies install-front-end-dependencies ## Install application dependencies (both back-end and front-end).

.PHONY: update-back-end-dependencies
update-back-end-dependencies: build-dev ## Update back-end dependencies.
	@$(DC_RUN) php composer update --prefer-dist --optimize-autoloader --no-interaction

.PHONY: update-front-end-dependencies
update-front-end-dependencies: ## Update front-end dependencies.
	@$(DC_RUN) node yarn upgrade-interactive --latest
	@$(DC_RUN) node yarn upgrade

.PHONY: update-dependencies
update-dependencies: update-back-end-dependencies update-front-end-dependencies ## Update all application dependencies (both back-end and front-end).

# Serve the application

.PHONY: proxy
proxy: traefik/ssl/_wildcard.docker.localhost.pem
	@make up IO=traefik

traefik/ssl/_wildcard.docker.localhost.pem:
	@cd ${CURDIR}/traefik/ssl && mkcert "*.docker.localhost"

.PHONY: cache
cache: install-back-end-dependencies ## Clear the Symfony cache.
	@$(DC_RUN) php rm -rf var/cache/*
	@$(DC_RUN) -e APP_ENV=${APP_ENV} php bin/console cache:clear

.PHONY: database
database: install-back-end-dependencies ## Setup the database.
	@make up IO=database
	@sh ${CURDIR}/docker/database/wait_for_it.sh
	@$(DC_RUN) php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration

.PHONY: dev
dev: database install-front-end-dependencies proxy #main# Serve the application in development mode.
	@echo ""
	@echo "Starting the application in development mode"
	@echo ""
	@make cache
	@make up IO=dev
	@echo ""
	@echo "The application is now running in development mode, you can access it through http://wishlist.docker.localhost"
	@echo ""

.PHONY: prod
prod: pull build-prod database proxy #main# Serve the application in production mode.
	@echo ""
	@echo "Starting the application in production mode"
	@echo ""
	@make up IO=nginx
	@echo ""
	@echo "The application is now running in production mode, you can access it through https://wishlist.docker.localhost"
	@echo ""

.PHONY: down
down: #main# Stop the application and remove all containers, networks and volumes.
	@docker-compose down -v

# Usefull aliases

.PHONY: console
console: #main# Use the Symfony CLI. Example: "make console IO=debug:container"
	@$(DC_RUN) php bin/console ${IO}

# Test the application

.PHONY: tests
tests: install-back-end-dependencies install-front-end-dependencies #main# Execute all the application tests.
	@echo ""
	@echo "Lint the PHP code"
	@echo ""
	@make lint-back-end-code
	@echo ""
	@echo "Lint the stylesheets"
	@echo ""
	@make stylelint
	@echo ""
	@echo "Lint the TypeScript code"
	@echo ""
	@make eslint
	@echo ""
	@echo "Run PHP static analysis"
	@echo ""
	@make analyse-back-end-code
	@echo ""
	@echo "Check for front-end type errors"
	@echo ""
	@make type-check-front-end
	@echo ""
	@echo "Check coupling violations between layers of the back-end code"
	@echo ""
	@make check-back-end-coupling
	@echo ""
	@echo "Run PHP Mess Detector"
	@echo ""
	@make phpmd
	@echo ""
	@echo "Execute back-end unit tests"
	@echo ""
	@make back-end-unit-tests
	@echo ""
	@echo "Execute front-end unit tests"
	@echo ""
	@make front-end-unit-tests
	@echo ""
	@echo "Execute \"in memory\" back-end acceptance tests"
	@echo ""
	@make back-end-acceptance-tests-in-memory
	@echo ""
	@echo "Execute \"in memory\" back-end integration tests"
	@echo ""
	@make back-end-integration-tests-in-memory
	@echo ""
	@echo "Execute back-end integration tests with I/O"
	@echo ""
	@make database
	@make back-end-integration-tests-with-io
	@echo ""
	@echo ""
	@echo "Execute back-end acceptance tests with I/O"
	@echo ""
	@make back-end-acceptance-tests-with-io
	@echo ""
	@echo "All tests were successfully executed"
	@echo ""

# Back-end tests

.PHONY: lint-back-end-code
lint-back-end-code: ## Check back-end coding style with PHP CS Fixer.
	@$(DC_RUN) php vendor/bin/php-cs-fixer fix --dry-run -v --diff --config=.php-cs-fixer.dist.php

.PHONY: fix-back-end-code
fix-back-end-code: ## Attempt to fix the violations detected by PHP CS Fixer.
	@$(DC_RUN) php vendor/bin/php-cs-fixer fix -v --diff --config=.php-cs-fixer.dist.php

.PHONY: analyse-back-end-src
analyse-back-end-src: ## Run PHP static analysis on source folder.
	@$(DC_RUN) php vendor/bin/phpstan analyse -l ${L} src

.PHONY: analyse-back-end-tests
analyse-back-end-tests: ## Run PHP static analysis on tests folder.
	@$(DC_RUN) php vendor/bin/phpstan analyse -l ${TL} tests

.PHONY: analyse-back-end-code ## Run static analysis on PHP code.
analyse-back-end-code: analyse-back-end-src analyse-back-end-tests

.PHONY: check-back-end-coupling
check-back-end-coupling: ## Check coupling violations between back-end code layers.
	@$(DC_RUN) php vendor/bin/php-coupling-detector detect --config-file .php_cd.php

.PHONY: phpmd
phpmd: ## Run PHP Mess Detector.
	@$(DC_RUN) php vendor/bin/phpmd src,tests --exclude *src/Kernel.php ${PHPMD_OUTPUT} ${PHPMD_RULESETS}

.PHONY: back-end-unit-tests
back-end-unit-tests: ## Execute back-end unit tests (use "make back-end-unit-tests IO=path/to/test" to run a specific test). Use "XDEBUG_MODE=debug make back-end-unit-tests" to activate the debugger.
ifeq ($(CI),true)
	@$(DC_RUN) php vendor/bin/phpspec run ${IO} --format=junit
else
	@$(DC_RUN) php vendor/bin/phpspec run ${IO}
endif

.PHONY: back-end-unit-tests
describe: ## Create a phpspec unit test (use as follow: "make describe IO=namepace/with/slash/instead/of/antislash", then running "make back-end-unit-tests" will create the class corresponding to the test).
	@$(DC_RUN) php vendor/bin/phpspec describe ${IO}

.PHONY: back-end-integration-tests-in-memory
back-end-integration-tests-in-memory: ## Execute back-end integration tests (use "make back-end-integration-tests-in-memory IO=path/to/test" to run a specific test). Use "XDEBUG_MODE=debug make back-end-integration-tests-in-memory" to activate the debugger.
	@$(DC_RUN) php vendor/bin/behat --profile=integration-in-memory -o std --colors -f pretty ${IO}

.PHONY: back-end-integration-tests-with-io
back-end-integration-tests-with-io: ## Execute back-end integration tests (use "make back-end-integration-tests-with-io IO=path/to/test" to run a specific test). Use "XDEBUG_MODE=debug make back-end-integration-tests-with-io" to activate the debugger.
	@$(DC_RUN) php vendor/bin/behat --profile=integration-with-io -o std --colors -f pretty ${IO}

.PHONY: back-end-acceptance-tests-in-memory
back-end-acceptance-tests-in-memory: ## Execute "in memory" back-end acceptance tests (use "make back-end-acceptance-tests-in-memory IO=path/to/test" to run a specific test). Use "XDEBUG_MODE=debug make back-end-acceptance-tests-in-memory" to activate the debugger.
	@$(DC_RUN) php vendor/bin/behat --profile=acceptance-in-memory -o std --colors -f pretty ${IO}

.PHONY: back-end-acceptance-tests-with-io
back-end-acceptance-tests-with-io: ## Execute back-end acceptance tests with I/O (use "make back-end-acceptance-tests-with-io IO=path/to/test" to run a specific test). Use "XDEBUG_MODE=debug make back-end-acceptance-tests-with-io" to activate the debugger.
	@$(DC_RUN) php vendor/bin/behat --profile=acceptance-with-io -o std --colors -f pretty ${IO}

.PHONY: phpmetrics
phpmetrics: ## Run PHP Metrics.
	@$(DC_RUN) php vendor/bin/phpmetrics --report-html=reports/phpmetrics .
	@xdg-open reports/phpmetrics/index.html

# Front-end tests

.PHONY: stylelint
stylelint: ## Lint the stylesheet code.
	@$(DC_RUN) node yarn -s stylelint

.PHONY: eslint
eslint: ## Lint the TypeScript code.
	@$(DC_RUN) node yarn -s eslint ${IO}

.PHONY: type-check-front-end
type-check-front-end: ## Check for front-end type errors.
	@$(DC_RUN) node yarn type-check

.PHONY: front-end-unit-tests
front-end-unit-tests: ## Execute front-end unit tests (use "make front-end-unit-tests IO=path/to/test" to run a specific test).
ifeq ($(CI),true)
	@$(DC_RUN) -e JEST_JUNIT_OUTPUT_DIR="./reports" -e JEST_JUNIT_OUTPUT_NAME="jest.xml" node yarn jest --watchAll=false --ci --reporters=default --reporters=jest-junit
else
	@$(DC_RUN) node yarn jest --watchAll ${IO}
endif
