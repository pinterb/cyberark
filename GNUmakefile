PKG_NAME=cyberark

GIT_REMOTE_URL := $(shell git config --get remote.origin.url)
GIT_COMMIT  = $(shell git rev-list -1 HEAD)
GIT_SHA := $(shell git rev-parse --short HEAD)
GIT_TAG := $(shell git describe --tags --abbrev=0 2>/dev/null)
GIT_VERSION := $(shell git describe --always --dirty)
GIT_DIRTY ?= $(shell test -n "`git status --porcelain`" && echo "dirty" || echo "clean")

default: build

build:
	@$(MAKE) gen
	@$(MAKE) fmt

gen: ## Generate code from OpenAPI specification file
	@oapi-codegen \
		-generate types \
		-o "$(CURDIR)/types.go" \
		-package "$(PKG_NAME)" \
		"$(CURDIR)/specs/api.yaml"
	@oapi-codegen \
		-generate client \
		-o "$(CURDIR)/client.go" \
		-package "$(PKG_NAME)" \
		"$(CURDIR)/specs/api.yaml"
	@go mod tidy

fmt: ## Format generated code
	@sh -c "'$(CURDIR)/scripts/gofmt.sh'"


generate-changelog: ## Generate changelog
	@echo "==> Generating changelog..."
	@sh -c "'$(CURDIR)/scripts/generate-changelog.sh'"

gencheck: ## Generated code checker
	@echo "==> Checking generated source code..."
	@$(MAKE) gen
	@git diff --compact-summary --exit-code || \
		(echo; echo "Unexpected difference in directories after code generation. Run 'make gen' command and commit."; exit 1)

fmtcheck:
	@sh -c "'$(CURDIR)/scripts/gofmtcheck.sh'"

depscheck: ## Golang dependency checker
	@echo "==> Checking source code with go mod tidy..."
	@go mod tidy
	@git diff --exit-code -- go.mod go.sum || \
		(echo; echo "Unexpected difference in go.mod/go.sum files. Run 'go mod tidy' command or revert any go.mod/go.sum changes and commit."; exit 1)

lint: fmtcheck golangci-lint  ## Perform linting

golangci-lint:
	@golangci-lint run ./...

tag: ## Tag a release
	@git tag -a "$(shell semver -d 0.0.1 -i)"
	@git push --tags

release: tag ## Cut a release
	goreleaser --rm-dist

tools: ## Install project tools
	cd tools && go install github.com/client9/misspell/cmd/misspell
	cd tools && go install github.com/golangci/golangci-lint/cmd/golangci-lint
	cd tools && go install github.com/hashicorp/go-changelog/cmd/changelog-build
	cd tools && go install github.com/deepmap/oapi-codegen/cmd/oapi-codegen
	cd tools && go install github.com/goreleaser/goreleaser
	cd tools && go install github.com/pinterb/go-semver/cmd/semver

# without the '-include' this would work:
# awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
# with an '-include' this would work:
# sed -e "s/^GNUmakefile://" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
help: ## Show this help screen
	@echo ''
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@echo 'Available targets are:'
	@echo ''
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ''

.PHONY: help build fmtcheck gen gencheck depscheck tools golangci-lint lint generate-changelog tag release
