#!/usr/bin/env bash

# Install base
if [ $(uname -s) == "Darwin" ]; then
    # Development Tools
    echo "Install homebrew bundle for development"
    brew bundle install --file $HOME/.dotfiles/Brewfile-development
elif [ $(uname -s) == "Linux" ]; then
    # Install Golang
    echo "Installing Golang..."
    source $HOME/.dotfiles/shellconfig/funcs.sh
    install_golang

    # Scala
    echo "Install Scala Coursier"
    pushd /tmp &&
    curl -fLo cs https://git.io/coursier-cli-linux &&
    chmod +x cs &&
    ./cs install cs
    rm ./cs
    popd
fi

# Scala
echo "Install Scala Coursier applications"
cs setup --yes --jvm graalvm --apps ammonite,bloop,cs,giter8,sbt,mill,scala,scalafmt,scalafix
cs update

# Golang
echo "Install Golang apps"
bash -c $HOME/.dotfiles/go_apps.sh

