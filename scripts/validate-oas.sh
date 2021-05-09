#!/usr/bin/env bash

# vim: filetype=sh:tabstop=2:shiftwidth=2:expandtab

readonly SCRIPT_DIR=$(basename $0)
readonly SCRIPT_NAME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOTDIR=$(git rev-parse --show-toplevel)

readonly OAS_FILE="specs/api.yaml"

readonly GO_PKG_ROOT=""
readonly GO_PKG="$GO_PKG_ROOT/"

readonly IMAGE="pinterb/openapi-validator:0.46.0"


###
# make sure we have the right tools installed
###
prereqs() {
  if ! command -v docker 1>/dev/null; then
    echo
    echo "it seems docker is not installed"
    echo
    echo "to validate the openapi spec file, you'll need docker installed"
    echo
    exit 1
  fi
}


validate_oas() {
  rm -f  "$ROOTDIR/validation.results"
  docker run \
    --rm \
    --volume "$ROOTDIR/specs":/data \
    "$IMAGE" api.yaml > "$ROOTDIR/validation.results"
}


###
# main
###
{
  prereqs
  validate_oas
}
