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
    curl -fLos cs https://git.io/coursier-cli-linux &&
    chmod +x cs &&
    ./cs install cs
    rm ./cs
    popd
fi

# Scala
if [ -x "$(command -v cs)" ] > /dev/null 2>&1; then
    echo "Install Scala Coursier applications"
    cs setup --yes \
        --jvm graalvm \
        --apps \
            ammonite, \
            bloop, \
            cs, \
            giter8, \
            sbt, \
            mill, \
            scala, \
            scalafmt
    cs update
fi

# Golang
echo "Install Golang apps"
bash -c $HOME/.dotfiles/go_apps.sh

