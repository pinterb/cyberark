#!/usr/bin/env bash

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

{
  echo "==> Formating golang..."
  post_gen_fmt
}

exit 0
