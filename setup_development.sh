#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

# Load utility functions
source "$HOME/.dotfiles/utils.sh"
source "$HOME/.dotfiles/shellconfig/exports.sh"
source "$HOME/.dotfiles/shellconfig/funcs.sh"

SUPPORTED_ARCHS=(x86_64 aarch64 ppc64le)
GRAALVM_ARCHS=(x86_64 aarch64)

if containsElement "$(uname -m)" "${SUPPORTED_ARCHS[@]}"; then
    log "Setup development tools on $(uname -m) architecture." "$GREENUNDER"
else
    log "Architecture $(uname -m) not supported by development tools." "$YELLOW"
    exit 0
fi

# Install MacOS Dev Tools
if [ "$(uname -s)" == "Darwin" ]; then
    # Development Tools
    log "Install homebrew bundle for development" "$GREEN"
    brew bundle install --file "$HOME/.dotfiles/mac/Brewfile-development" || true
    # Fix for GTKWave from command line
    sudo cpan install Switch
    # Link Erlang Language Server config file
    mkdir -p "$HOME/Library/Application\ Support/erlang_ls"
    ln -sf "$HOME/.dotfiles/rc/config/erlang_ls/erlang_ls.config" "$HOME/Library/Application\ Support/erlang_ls/erlang-ls.config"


# Install Linux Dev Tools
elif [ "$(uname -s)" == "Linux" ]; then
    # Install Golang
    log "Installing Golang..." "$GREEN"
    install_golang

    # Java / Scala / Coursier
    # Install Coursier
    if [ ! -x "$(command -v cs)" ] > /dev/null 2>&1; then
        log "Install Coursier" "$GREEN"
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
# The [JVM](./shellconfig/exports.sh) env is defined in exports.sh
if [ -x "$(command -v cs)" ] > /dev/null 2>&1; then
    # Install JVM using Coursier if supported
    if containsElement "$(uname -m)" "${GRAALVM_ARCHS[@]}"; then
        cs install --jvm "${JVM}"
    fi
    JAVA_HOME=$(cs java-home)
    export JAVA_HOME
    export PATH=$JAVA_HOME/bin:$PATH
    log "Install Scala Coursier applications" "$GREEN"
    # Java version comes from JVM var in `shellconfig/exports.sh`
    cs install \
        cs \
        giter8 \
        bloop-jvm \
        sbt \
        scala \
        scalafmt \
        scalafix \
        scala-cli
    cs update
fi

# Install GraalVM native-image utility
if [ -x "$(command -v gu)" ] > /dev/null 2>&1; then
    if [ "$(uname -s)" == "Darwin" ]; then
        gu install native-image
    elif [ "$(uname -s)" == "Linux" ]; then
        sudo env PATH="$PATH" JAVA_HOME="$JAVA_HOME" gu install native-image
    fi
fi

log "Development tools setup finished." "$GREENUNDER"
