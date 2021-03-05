#!/usr/bin/env bash
set -euo pipefail

# Load utility functions
source $HOME/.dotfiles/utils.sh
source ~/.dotfiles/shellconfig/exports.sh
source $HOME/.dotfiles/shellconfig/funcs.sh

log "Setup development tools." $GREENUNDER

# Install base
if [ $(uname -s) == "Darwin" ]; then
    # Development Tools
    log "Install homebrew bundle for development" $GREEN
    brew bundle install --file $HOME/.dotfiles/mac/Brewfile-development
elif [ $(uname -s) == "Linux" ]; then
    # Install Golang
    log "Installing Golang..." $GREEN
    #install_golang

    # Scala Coursier
    if [ ! -x "$(command -v cs)" ] > /dev/null 2>&1; then
        log "Install Scala Coursier" $GREEN
        pushd /tmp >/dev/null
        dlgr coursier/coursier cs
        if test -f cs; then
            chmod +x cs
            ./cs install cs
            rm ./cs
        else
            echo "No Coursier available for your platform"
        fi
        popd >/dev/null
    fi
fi

# Scala
if [ -x "$(command -v cs)" ] > /dev/null 2>&1; then
    log "Install Scala Coursier applications" $GREEN
    cs install --jvm ${JVM} \
            ammonite \
            cs \
            giter8 \
            bloop-jvm \
            sbt \
            sbtn \
            mill \
            scala \
            scalafmt
    cs update
fi

log "Development tools setup finished." $GREENUNDER
