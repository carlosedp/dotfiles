#!/usr/bin/env bash

# Install base
if [ $(uname -s) == "Darwin" ]; then
    # Development Tools
    brew bundle install --file $DOTFILES/Brewfile-development
elif [ $(uname -s) == "Linux" ]; then
    # Install Golang
    echo "Installing Golang..."
    source $DOTFILES/shellconfig/funcs.sh
    install_golang

    # Scala
    pushd /tmp &&
    curl -fLo cs https://git.io/coursier-cli-linux &&
    chmod +x cs &&
    ./cs install cs
    rm ./cs
    popd
fi

# Scala
cs setup --yes --jvm graalvm --apps ammonite,bloop,cs,giter8,sbt,mill,scala,scalafmt,scalafix
cs update

# Golang
bash -c $DOTFILES/go_apps.sh

