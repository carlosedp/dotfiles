#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

SUPPORTED_ARCHS=(x86_64 aarch64)

# Load utility functions
source "$HOME/.dotfiles/utils.sh"

# Install Go apps
export PATH=/usr/local/go/bin:"$PATH"
log "Installing Go apps..." "$GREENUNDER"
echo ""

apps=("github.com/github/hub/v2@master"
        "rsc.io/2fa@latest"
        "golang.org/x/tools/cmd/benchcmp@latest"
        "github.com/traefik/yaegi/cmd/yaegi@latest"
        "github.com/rakyll/hey@latest"
        "github.com/junegunn/fzf@latest"
        "github.com/brancz/gojsontoyaml@master"
)

# Only run if Go is present
if [ -x "$(command -v go)" ] > /dev/null 2>&1; then
    for m in "${apps[@]}"; do
        log "Installing $m" "$GREEN"
        go install "$m"
    done

else
    log "ERROR: You don't have Go installed." "$RED"
    exit 1
fi

log "Go apps installed." "$GREENUNDER"

# Linux app install
if [ "$(uname -s)" == "Linux" ]; then
    log "Installing Linux apps..." "$GREENUNDER"
    # Install Kubectl
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
    sudo curl -o /usr/local/bin/kubectl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl"
    sudo chmod +x /usr/local/bin/kubectl
    export PATH="/usr/local/bin/:$PATH"

    # Install Kubernetes Krew
    if containsElement "$(uname -m)" "${SUPPORTED_ARCHS[@]}"; then
        (
        set -x; cd "$(mktemp -d)" &&
        OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
        ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
        curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-${OS}_${ARCH}.tar.gz" &&
        tar zxvf "./krew-${OS}_${ARCH}.tar.gz" &&
        KREW=./krew-"${OS}_${ARCH}" &&
        "$KREW" install krew
        )
    fi
fi

log "Upgrade and install kubectl plugins." "$GREENUNDER"
export PATH="/usr/local/bin/:${HOME}/.krew/bin:${PATH}"
kubectl krew upgrade
for app in ctx ns restart; do
    kubectl krew install $app;
done

# Mac App configs
# if [ "$(uname -s)" == "Darwin" ]; then
    ## Limechat settings
    # mkdir -p "$HOME/Library/Application\ Support/net.limechat.LimeChat-AppStore/Themes"
    # cp "$HOME/.dotfiles/themes/Limechat-Choco/*" "$HOME/Library/Application\ Support/net.limechat.LimeChat-AppStore/Themes"
# fi
