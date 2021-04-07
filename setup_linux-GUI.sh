#!/usr/bin/env bash
set -euo pipefail

# Load utility functions
source "$HOME/.dotfiles/utils.sh"

cd "$HOME"

log "Setup Linux with GUI..." "$GREENUNDER"

BASEPACKAGES="terminator"

# Install Linux packages
source /etc/os-release
if [ "$ID" == "debian" ] || [ "$ID" == "ubuntu" ]; then
    sudo apt update
    sudo apt upgrade -y
    for i in $BASEPACKAGES; do
        sudo apt install --no-install-recommends $i
    done
elif [ "$ID" == "fedora" ] || [ "$ID" == "centos" ]; then
    sudo dnf update -y
    sudo dnf install -y $BASEPACKAGES
elif [ "$ID" == "alpine" ]; then
    sudo apk update
    sudo apk add $BASEPACKAGES
elif [ "$ID" == "void" ]; then
    sudo xbps-install -Su -y $BASEPACKAGES
fi

# Install Fonts
sudo tar vxf "$HOME"/.dotfiles/fonts/FC.tar.gz -C /usr/share/fonts
sudo tar vxf "$HOME"/.dotfiles/fonts/NF.tar.gz -C /usr/share/fonts

# Install VS Code
if [ "$ID" == "debian" ] || [ "$ID" == "ubuntu" ]; then
    sudo bash -c ". <( wget -O - https://code.headmelted.com/installers/apt.sh )"
elif [ "$ID" == "fedora" ] || [ "$ID" == "centos" ]; then
    sudo bash -c ". <( wget -O - https://code.headmelted.com/installers/yum.sh )"
fi
sudo ln -sf /usr/bin/code-oss /usr/local/bin/code

log "Linux GUI setup finished." "$GREENUNDER"
