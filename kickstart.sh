#!/usr/bin/env bash
set -euo pipefail

# Minimal required packages: curl, bash, sudo
# To install, run curl -Lks https://github.com/carlosedp/dotfiles/raw/master/kickstart.sh | bash
# Load Linux distro info
if [ $(uname -s) != "Darwin" ]; then
    if [ -f /etc/os-release ]; then
        source /etc/os-release
    else
        echo "ERROR: I need the file /etc/os-release to determine the Linux distribution..."
        exit 1
    fi
fi

if [[ ! $(command -v git) ]]; then
    # Install Git on Linux
    if [ $ID == "debian" ] || [ $ID == "ubuntu" ]; then
        sudo apt update
        sudo apt install --no-install-recommends -y git
    elif [ $ID == "fedora" ] || [ $ID == "centos" ] || [ $ID == "rhel" ]; then
        sudo dnf install -y git
    elif [ $ID == "alpine" ]; then
        sudo apk add git
    elif [ $ID == "void" ]; then
        sudo xbps-install -Su -y git
    else
        echo "Your distro is not supported, install git manually."
        exit 1
    fi
fi

# Clone dotfiles into $HOME
echo "Cloning dotfiles..."
git clone --quiet https://github.com/carlosedp/dotfiles.git $HOME/.dotfiles

# Run setup script
echo "Running setup script..."
if [ $(uname -s) == "Darwin" ]; then
    $HOME/.dotfiles/setup_mac.sh
else
    $HOME/.dotfiles/setup_linux.sh
fi
