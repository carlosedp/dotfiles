#!/usr/bin/env bash

# Install Go apps

export PATH=/usr/local/go/bin:"$PATH"
echo "Installing Go apps..."
echo ""

modules=("github.com/github/hub"
        "rsc.io/2fa"
        "golang.org/x/tools/cmd/benchcmp"
        "github.com/containous/yaegi/cmd/yaegi"
        "github.com/ahmetb/kubectx/cmd/kubectx"
        "github.com/ahmetb/kubectx/cmd/kubens"
        "github.com/rakyll/hey"
)

# Only run if Go is present
if [ -x "$(command -v go)" ] > /dev/null 2>&1; then

    # Install applications with module mode off to avoid
    # updating any project go.mod/go.sum if inside it's directories
    for m in ${modules[@]}; do
        echo "Installing " $m
        GO111MODULE=off go get -u $m
    done

else
    echo "ERROR: You don't have Go installed."
    exit 1
fi
