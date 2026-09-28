# Generated Go code output directory (committed so consumers do not need
# the toolchain -- regenerate after every .proto change).
GEN_DIR := apis-go

# Input used by `make breaking`. Needs at least one commit on master before
# the first run (e.g. `git add -A && git commit -m "init proto modules"`).
BUF_BREAKING_AGAINST ?= .git#branch=master

.PHONY: \
	generate \
	lint \
	format \
	format-check \
	breaking \
	verify \
	generate-check \
	clean

generate: install-codegen-tools ## Generate Go, gateway and OpenAPI code from proto files
	@printf "$(CYAN)▶ Generating Go code from proto files...$(RESET)\n"
	@buf generate
	@printf "$(BOLD)$(GREEN)Generated code is up to date in $(GEN_DIR).$(RESET)\n"

lint: install-buf ## Lint proto files (buf lint)
	@printf "$(CYAN)▶ Linting proto files...$(RESET)\n"
	@buf lint
	@printf "$(BOLD)$(GREEN)Proto files pass lint.$(RESET)\n"

format: ## Format proto files in place
	@buf format -w
	@printf "$(BOLD)$(GREEN)Proto files are formatted.$(RESET)\n"

format-check: ## Check proto files are formatted (fails on diff)
	@buf format --diff --exit-code

breaking: ## Check breaking changes against $(BUF_BREAKING_AGAINST)
	@printf "$(CYAN)▶ Checking breaking changes against $(BUF_BREAKING_AGAINST)...$(RESET)\n"
	@buf breaking --against '$(BUF_BREAKING_AGAINST)'
	@printf "$(BOLD)$(GREEN)No breaking changes detected.$(RESET)\n"

verify: lint format-check generate ## Lint, format-check and regenerate everything
	@go build ./...

generate-check: generate ## Fail when the committed generated code is stale
	@git diff --exit-code -- $(GEN_DIR) openapi || (printf "$(RED)Generated code is stale: run make generate and commit.$(RESET)\n"; exit 1)
	@test -z "$$(git status --porcelain -- $(GEN_DIR) openapi)" || (git status --short -- $(GEN_DIR) openapi; printf "$(RED)Untracked generated files: run make generate and commit.$(RESET)\n"; exit 1)
	@printf "$(BOLD)$(GREEN)All checks passed.$(RESET)\n"

clean: ## Remove generated Go code
	@rm -rf $(GEN_DIR)
	@printf "$(BOLD)$(GREEN)Removed $(GEN_DIR).$(RESET)\n"
