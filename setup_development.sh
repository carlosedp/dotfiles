#!/usr/bin/env bash
set -euo pipefail

# Load utility functions
source "$HOME/.dotfiles/utils.sh"
source "$HOME/.dotfiles/shellconfig/exports.sh"
source "$HOME/.dotfiles/shellconfig/funcs.sh"

SUPPORTED_ARCHS=(x86_64 aarch64 ppc64le)

if containsElement "$(uname -m)" "${SUPPORTED_ARCHS[@]}"; then
            log "Setup development tools on $(uname -m) architecture." "$GREENUNDER"
        else
            log "Architecture $(uname -m) not supported by development tools." "$YELLOW"
            exit 0
        fi

# Install base
if [ "$(uname -s)" == "Darwin" ]; then
    # Development Tools
    log "Install homebrew bundle for development" "$GREEN"
    brew bundle install --file "$HOME/.dotfiles/mac/Brewfile-development"
    # Fix for GTKWave from command line
    sudo cpan install Switch
elif [ "$(uname -s)" == "Linux" ]; then
    # Install Golang
    log "Installing Golang..." "$GREEN"
    install_golang

    # Scala Coursier
    if [ ! -x "$(command -v cs)" ] > /dev/null 2>&1; then
        log "Install Scala Coursier" "$GREEN"
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
    log "Install Scala Coursier applications" "$GREEN"
    cs install --jvm "${JVM}" \
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

# Install GraalVM native-image utility
if [ -x "$(command -v gu)" ] > /dev/null 2>&1; then
    gu install native-image
fi

log "Development tools setup finished." "$GREENUNDER"
