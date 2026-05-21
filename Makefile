# ==============================================================================
# Makefile — Terraform Workflow Automation
# ==============================================================================
# Usage:
#   make init                    # Initialize Terraform
#   make plan ENV=dev            # Plan with dev vars
#   make apply ENV=prod          # Apply with prod vars
#   make destroy ENV=dev         # Destroy dev environment
#   make fmt                     # Format all .tf files
#   make validate                # Validate configuration
#   make lint                    # Format + Validate
#   make backend-init            # Initialize backend infrastructure
#   make backend-apply           # Deploy backend (S3 + DynamoDB)
# ==============================================================================

.PHONY: init plan apply destroy fmt validate lint clean docs backend-init backend-apply

# Default environment
ENV ?= dev
TFVARS := envs/$(ENV).tfvars

# Colors
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
NC     := \033[0m

# --- Core Terraform Commands ---

init: ## Initialize Terraform working directory
	@echo "$(GREEN)>>> Initializing Terraform...$(NC)"
	terraform init -upgrade

plan: validate ## Generate and show execution plan
	@echo "$(GREEN)>>> Planning ($(ENV))...$(NC)"
	terraform plan -var-file=$(TFVARS) -out=tfplan

apply: ## Apply changes (requires plan)
	@echo "$(YELLOW)>>> Applying ($(ENV))...$(NC)"
	@if [ -f tfplan ]; then \
		terraform apply tfplan; \
	else \
		terraform apply -var-file=$(TFVARS); \
	fi

destroy: ## Destroy all resources
	@echo "$(RED)>>> Destroying ($(ENV))...$(NC)"
	terraform destroy -var-file=$(TFVARS)

# --- Quality Commands ---

fmt: ## Format Terraform files
	@echo "$(GREEN)>>> Formatting...$(NC)"
	terraform fmt -recursive

validate: ## Validate Terraform configuration
	@echo "$(GREEN)>>> Validating...$(NC)"
	terraform validate

lint: fmt validate ## Format + Validate
	@echo "$(GREEN)>>> Lint passed!$(NC)"

# --- Backend Commands ---

backend-init: ## Initialize backend infrastructure
	@echo "$(GREEN)>>> Initializing backend...$(NC)"
	cd backend && terraform init

backend-apply: backend-init ## Deploy backend (S3 + DynamoDB)
	@echo "$(GREEN)>>> Deploying backend...$(NC)"
	cd backend && terraform apply

# --- Utility Commands ---

clean: ## Remove local Terraform files
	@echo "$(YELLOW)>>> Cleaning...$(NC)"
	rm -rf .terraform .terraform.lock.hcl tfplan
	rm -rf backend/.terraform backend/.terraform.lock.hcl

output: ## Show Terraform outputs
	terraform output

docs: ## Show project structure
	@echo "$(GREEN)Project Structure:$(NC)"
	@find . -name '*.tf' -o -name '*.tfvars' -o -name '*.md' | sort | head -50

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
