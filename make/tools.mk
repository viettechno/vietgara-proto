# Tool versions (pinned). The backend pins its runtime deps the same way --
# see vietgara-backend/make/install.mk.
BUF_VERSION                := 1.72.0
PROTOC_GEN_GO_VERSION      := v1.36.11
PROTOC_GEN_GO_GRPC_VERSION := v1.6.2
# protoc-gen-grpc-gateway and protoc-gen-openapiv2 match the grpc-gateway runtime in go.mod.
GRPC_GATEWAY_VERSION       := v2.30.0
GRPCUI_VERSION             := v1.5.3
GRPCURL_VERSION            := v1.8.7

.PHONY: \
	install-tools \
	install-codegen-tools \
	install-buf \
	install-protoc-gen-go \
	install-protoc-gen-go-grpc \
	install-grpc-gateway \
	install-grpcui \
	install-grpcurl

install-tools: install-codegen-tools install-grpcui install-grpcurl ## Install every pinned proto tool
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

install-codegen-tools: install-buf install-protoc-gen-go install-protoc-gen-go-grpc install-grpc-gateway ## Install the pinned tools `make generate` needs

# The plugins report no version, so the pinned one is read from build info.
install-grpc-gateway: ## Install protoc-gen-grpc-gateway and protoc-gen-openapiv2 $(GRPC_GATEWAY_VERSION)
	@installed_version="$$(command -v protoc-gen-openapiv2 >/dev/null 2>&1 && command -v protoc-gen-grpc-gateway >/dev/null 2>&1 && go version -m "$$(command -v protoc-gen-openapiv2)" 2>/dev/null | grep -E '^[[:space:]]*mod[[:space:]]' | awk '{print $$3}' || true)"; \
	if [ "$$installed_version" = "$(GRPC_GATEWAY_VERSION)" ]; then \
		echo "$(BOLD)$(GREEN)grpc-gateway plugins $(GRPC_GATEWAY_VERSION) are already installed.$(RESET)"; \
	else \
		echo "$(BOLD)$(BLUE)Installing grpc-gateway plugins $(GRPC_GATEWAY_VERSION)...$(RESET)"; \
		go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@$(GRPC_GATEWAY_VERSION); \
		go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@$(GRPC_GATEWAY_VERSION); \
		echo "$(BOLD)$(GREEN)grpc-gateway plugins $(GRPC_GATEWAY_VERSION) installed.$(RESET)"; \
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

install-grpcurl: ## Install grpcurl $(GRPCURL_VERSION)
	@installed_version="$$(grpcurl --version 2>/dev/null | grep -o 'grpcurl [^ ]*' | awk '{print $$2}' || true)"; \
	if [ "$$installed_version" = "$(GRPCURL_VERSION)" ]; then \
		echo "$(BOLD)$(GREEN)grpcurl $(GRPCURL_VERSION) is already installed.$(RESET)"; \
	else \
		echo "$(BOLD)$(BLUE)Installing grpcurl $(GRPCURL_VERSION)...$(RESET)"; \
		go install github.com/fullstorydev/grpcurl/cmd/grpcurl@$(GRPCURL_VERSION); \
		echo "$(BOLD)$(GREEN)grpcurl $(GRPCURL_VERSION) installed.$(RESET)"; \
	fi
