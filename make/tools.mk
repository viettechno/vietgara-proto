# Tool versions (pinned). The backend pins its runtime deps the same way --
# see vietgara-backend/make/install.mk.
BUF_VERSION                := 1.72.0
PROTOC_GEN_GO_VERSION      := v1.36.11
PROTOC_GEN_GO_GRPC_VERSION := v1.6.2
GRPCUI_VERSION             := v1.5.3

.PHONY: \
	install-tools \
	install-buf \
	install-protoc-gen-go \
	install-protoc-gen-go-grpc \
	install-grpcui

install-tools: install-buf install-protoc-gen-go install-protoc-gen-go-grpc install-grpcui ## Install pinned proto codegen tools
	@echo "$(BOLD)$(GREEN)Proto codegen tools are ready.$(RESET)"
	@echo "$(YELLOW)Note: ensure GOBIN (or GOPATH/bin) is on your PATH so buf can find the plugins.$(RESET)"

install-buf: ## Install buf $(BUF_VERSION)
	@installed_version="$$(buf --version 2>/dev/null || true)"; \
	if [ "$$installed_version" = "$(BUF_VERSION)" ]; then \
		echo "$(BOLD)$(GREEN)buf $(BUF_VERSION) is already installed.$(RESET)"; \
	else \
		echo "$(BOLD)$(BLUE)Installing buf $(BUF_VERSION)...$(RESET)"; \
		go install github.com/bufbuild/buf/cmd/buf@v$(BUF_VERSION); \
		echo "$(BOLD)$(GREEN)buf $(BUF_VERSION) installed.$(RESET)"; \
	fi

install-protoc-gen-go: ## Install protoc-gen-go $(PROTOC_GEN_GO_VERSION)
	@installed_version="$$(protoc-gen-go --version 2>/dev/null | grep -o 'v[0-9.]*' | head -1 || true)"; \
	if [ "$$installed_version" = "$(PROTOC_GEN_GO_VERSION)" ]; then \
		echo "$(BOLD)$(GREEN)protoc-gen-go $(PROTOC_GEN_GO_VERSION) is already installed.$(RESET)"; \
	else \
		echo "$(BOLD)$(BLUE)Installing protoc-gen-go $(PROTOC_GEN_GO_VERSION)...$(RESET)"; \
		go install google.golang.org/protobuf/cmd/protoc-gen-go@$(PROTOC_GEN_GO_VERSION); \
		echo "$(BOLD)$(GREEN)protoc-gen-go $(PROTOC_GEN_GO_VERSION) installed.$(RESET)"; \
	fi

install-protoc-gen-go-grpc: ## Install protoc-gen-go-grpc $(PROTOC_GEN_GO_GRPC_VERSION)
	@installed_version="$$(protoc-gen-go-grpc --version 2>/dev/null | grep -o 'v[0-9.]*' | head -1 || true)"; \
	if [ "$$installed_version" = "$(PROTOC_GEN_GO_GRPC_VERSION)" ]; then \
		echo "$(BOLD)$(GREEN)protoc-gen-go-grpc $(PROTOC_GEN_GO_GRPC_VERSION) is already installed.$(RESET)"; \
	else \
		echo "$(BOLD)$(BLUE)Installing protoc-gen-go-grpc $(PROTOC_GEN_GO_GRPC_VERSION)...$(RESET)"; \
		go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@$(PROTOC_GEN_GO_GRPC_VERSION); \
		echo "$(BOLD)$(GREEN)protoc-gen-go-grpc $(PROTOC_GEN_GO_GRPC_VERSION) installed.$(RESET)"; \
	fi

# grpcui built via `go install` reports "dev build" from -version, so the
# pinned version is read from the binary's build info instead.
install-grpcui: ## Install grpcui $(GRPCUI_VERSION)
	@installed_version="$$(command -v grpcui >/dev/null 2>&1 && go version -m "$$(command -v grpcui)" 2>/dev/null | grep -E '^[[:space:]]*mod[[:space:]]' | awk '{print $$3}' || true)"; \
	if [ "$$installed_version" = "$(GRPCUI_VERSION)" ]; then \
		echo "$(BOLD)$(GREEN)grpcui $(GRPCUI_VERSION) is already installed.$(RESET)"; \
	else \
		echo "$(BOLD)$(BLUE)Installing grpcui $(GRPCUI_VERSION)...$(RESET)"; \
		go install github.com/fullstorydev/grpcui/cmd/grpcui@$(GRPCUI_VERSION); \
		echo "$(BOLD)$(GREEN)grpcui $(GRPCUI_VERSION) installed.$(RESET)"; \
	fi
