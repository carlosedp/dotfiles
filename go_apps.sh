#!/usr/bin/env bash
set -euo pipefail

# Load utility functions
source $HOME/.dotfiles/utils.sh

# Install Go apps

export PATH=/usr/local/go/bin:"$PATH"
log "Installing Go apps..." $GREENUNDER
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
        log "Installing $m" $GREEN
        GO111MODULE=off go get -u $m || true
    done

else
    log "ERROR: You don't have Go installed." $RED
    exit 1
fi

log "Go apps installed." $GREENUNDER