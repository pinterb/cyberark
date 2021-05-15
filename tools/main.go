// +build tools

package main

import (
	_ "github.com/client9/misspell/cmd/misspell"
	_ "github.com/deepmap/oapi-codegen/cmd/oapi-codegen"
	_ "github.com/golangci/golangci-lint/cmd/golangci-lint"
	_ "github.com/goreleaser/goreleaser"
	_ "github.com/hashicorp/go-changelog/cmd/changelog-build"
	_ "github.com/pinterb/go-semver/cmd/semver"
)
