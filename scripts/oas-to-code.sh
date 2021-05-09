#!/usr/bin/env bash

# vim: filetype=sh:tabstop=2:shiftwidth=2:expandtab

readonly SCRIPT_DIR=$(basename $0)
readonly SCRIPT_NAME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOTDIR=$(git rev-parse --show-toplevel)

readonly OAS_FILE="specs/api.yaml"

readonly GO_PKG_ROOT=""
readonly GO_PKG="$GO_PKG_ROOT/"

readonly DEEPMAP_CODEGEN="cyberark"
#readonly GO_PKG_DEEPMAP="$GO_PKG_ROOT/$DEEPMAP_CODEGEN"


###
# make sure we have the right tools installed
###
prereqs() {
  if ! command -v oapi-codegen 1>/dev/null; then
    echo
    echo "it seems oapi-codegen is not installed"
    echo
    echo "...will attempt to install"
    echo
    go get github.com/deepmap/oapi-codegen/cmd/oapi-codegen
  fi
}


###
# the deepmap code generator
# see: https://github.com/deepmap/oapi-codegen
###
gen_deepmap_code() {

  if [ ! -f "$ROOTDIR/go.mod" ]; then
    cd "$ROOTDIR" && go mod init github.com/pinterb/cyberark
  fi

  oapi-codegen \
    -generate types \
    -o "$ROOTDIR/types.go" \
    -package "cyberark" \
    "$ROOTDIR/specs/api.yaml"

  oapi-codegen \
    -generate client \
    -o "$ROOTDIR/client.go" \
    -package "cyberark" \
    "$ROOTDIR/specs/api.yaml"

  if [ ! -f "$ROOTDIR/go.mod" ]; then
    cd "$ROOTDIR" && go mod init github.com/pinterb/cyberark
  fi

  cd "$ROOTDIR" && go mod tidy
}


###
# after generating code, perform golang formatting
###
post_gen_fmt() {
  dirs=$(go list -f {{.Dir}} ./...)
  test -z "`for d in $dirs; do goimports -l $d/*.go | tee /dev/stderr; done`"

  if command -v gofmt 1>/dev/null; then
    test -z "`for d in $dirs; do gofmt -s -w $d/*.go | tee /dev/stderr; done`"
  #  cd "$ROOTDIR" && gofmt -s -w .
  else
    echo
    echo "gofmt is not installed locally, formatting skipped"
    echo
  fi

  if command -v goimports 1>/dev/null; then
    test -z "`for d in $dirs; do goimports -w $d/*.go | tee /dev/stderr; done`"
  else
    echo
    echo "goimports is not installed locally, formatting skipped"
    echo
  fi
}


###
# after generating code, remove an unneeded, unwanted files
# so far, only looks for openapitools-related files
###
post_gen_cleanup() {
  # declare auto-generated files that we can remove from the generated directory
  declare -a scraps=(".gitignore" ".travis.yml" "go.mod" "go.sum" "git_push.sh" ".openapi-generator-ignore")
  for i in "${scraps[@]}"
  do
    if [ -f "$ROOTDIR/$GO_PKG/$i" ]; then
      rm "$ROOTDIR/$GO_PKG/$i"
    fi
  done
}


###
# main
###
{
  prereqs
  gen_deepmap_code

  post_gen_fmt
  post_gen_cleanup
}
