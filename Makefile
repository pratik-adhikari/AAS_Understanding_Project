SHELL := /bin/bash
COMPOSE := docker compose

.DEFAULT_GOAL := help

.PHONY: help init prerequisites config pull build generate up ps logs smoke \
	down clean format-check lint unit integration verify

help:
	@awk 'BEGIN {FS = ":.*##"; printf "AAS learning project commands:\\n\\n"} /^[a-zA-Z_-]+:.*?##/ {printf "  %-18s %s\\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Create the local .env file from documented development defaults
	@test -f .env || cp .env.example .env
	@echo ".env is ready"

prerequisites: ## Check required host tools and Docker daemon access
	@./scripts/check-prerequisites.sh

config: init ## Validate and render the Compose configuration
	@mkdir -p artifacts
	@$(COMPOSE) config --quiet
	@$(COMPOSE) config > artifacts/compose.rendered.yaml
	@echo "Compose configuration is valid"

pull: init ## Pull all pinned runtime images
	@$(COMPOSE) pull

build: init ## Build the pinned Python AAS tooling image
	@$(COMPOSE) --profile tools build aas-tooling

generate: build ## Generate JSON and AASX from source product data
	@install -d -m 0777 data/generated
	@$(COMPOSE) --profile tools run --rm aas-tooling generate

up: init ## Start the baseline AAS infrastructure
	@$(COMPOSE) up -d --wait
	@$(MAKE) ps

ps: ## Show project container and health status
	@$(COMPOSE) ps

logs: ## Follow service logs
	@$(COMPOSE) logs -f --tail=200

smoke: ## Verify baseline HTTP endpoints
	@./scripts/smoke.sh

down: ## Stop containers while preserving persistent volumes
	@$(COMPOSE) down --remove-orphans

clean: ## Remove all project containers, networks, and persistent volumes
	@$(COMPOSE) down --volumes --remove-orphans
	@echo "Project runtime state removed"

format-check: ## Check whitespace and generated-file policy
	@git diff --check
	@./scripts/check-repository.sh

lint: format-check config ## Run static repository and Compose checks
	@./scripts/check-image-tags.sh

unit: build ## Run isolated model and packaging tests in the tooling container
	@$(COMPOSE) --profile tools run --rm aas-tooling test

integration: up ## Run live API integration checks
	@./scripts/smoke.sh

verify: lint unit integration ## Run the canonical complete verification pipeline
	@echo "Baseline verification passed"
