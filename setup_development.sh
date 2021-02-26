#!/usr/bin/env bash
set -euo pipefail

# Load utility functions
source $HOME/.dotfiles/utils.sh

log "Setup development tools." $GREENUNDER

# Install base
if [ $(uname -s) == "Darwin" ]; then
    # Development Tools
    log "Install homebrew bundle for development" $GREEN
    brew bundle install --file $HOME/.dotfiles/mac/Brewfile-development
elif [ $(uname -s) == "Linux" ]; then
    # Install Golang
    log "Installing Golang..." $GREEN
    source $HOME/.dotfiles/shellconfig/funcs.sh
    install_golang

    # Scala (Only install on some archs)
    if [ $(uname -m) == "x86_64" ] || [ $(uname -m) == "aarch64" ]; then
        log "Install Scala Coursier" $GREEN
        pushd /tmp >/dev/null
        curl -fLso cs https://git.io/coursier-cli-linux
        chmod +x cs
        ./cs install cs
        rm ./cs
        popd >/dev/null
    fi
fi

# Scala
source ~/.dotfiles/shellconfig/exports.sh
if [ -x "$(command -v cs)" ] > /dev/null 2>&1; then
    log "Install Scala Coursier applications" $GREEN
    cs install --jvm graalvm \
            ammonite \
            bloop \
            cs \
            giter8 \
            sbt \
            mill \
            scala \
            scalafmt
    cs update
fi

log "Development tools setup finished." $GREENUNDER