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

# Install MacOS Dev Tools
if [ "$(uname -s)" == "Darwin" ]; then
    # Development Tools
    log "Install homebrew bundle for development" "$GREEN"
    brew bundle install --file "$HOME/.dotfiles/mac/Brewfile-development"
    # Fix for GTKWave from command line
    sudo cpan install Switch


# Install Linux Dev Tools
elif [ "$(uname -s)" == "Linux" ]; then
    # Install Golang
    log "Installing Golang..." "$GREEN"
    install_golang

    # Java / Scala / Coursier
    # First install Java
    log "Installing Java..." "$GREEN"
    pushd /tmp >/dev/null
    dlgr graalvm/graalvm-ce-builds java.tar.gz "${JVM}"
    if test -f java.tar.gz; then
        sudo mkdir -p /usr/local/java
        sudo tar vxf java.tar.gz -C /usr/local/java --strip-components=1
        rm -f java.tar.gz
        popd >/dev/null
        export JAVA_HOME=/usr/local/java
        export PATH=${JAVA_HOME}/bin:${PATH}
    else
        echo "No Java available for your platform"
    fi

    # then install Coursier
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
    # Install JVM on MacOS using Coursier
    if [ "$(uname -s)" == "Darwin" ]; then
        cs install --jvm "${JVM}"
    fi
    export JAVA_HOME=$(cs java-home)
    export PATH=$JAVA_HOME/bin:$PATH
    log "Install Scala Coursier applications" "$GREEN"
    # Java version comes from JVM var in `shellconfig/exports.sh`
    cs install \
        ammonite \
        cs \
        giter8 \
        bloop-jvm \
        sbt \
        mill \
        scala \
        scalafmt
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
