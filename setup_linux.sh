#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

# Load utility functions
source "$HOME/.dotfiles/utils.sh"

log "Setup Linux..." "$GREENUNDER"

DOTFILES="$HOME/.dotfiles"
cd "$HOME"

BASEPACKAGES="sudo curl wget git file dbus bc bash-completion hdparm sysstat less vim iptables ipset pciutils iperf3 net-tools jq haveged htop zsh tmux neofetch lshw iotop rsync tree autojump bat lm-sensors bpytop cargo"
DEBIANPACKAGES="openssh-client openssh-server locales ack-grep nfs-common apt-utils build-essential lsb-release telnet xz-utils apt-rdepends"
FEDORAPACKAGES="openssh-client openssh-server ack nfs-utils @development-tools which lsb-release telnet xz"
ALPINEPACKAGES="openssh-client openssh-server ack nfs-utils build-base xz"
VOIDPACKAGES="base-devel openssh inetutils-telnet xz"

# Install Linux packages
source /etc/os-release
if [ "$ID" == "debian" ] || [ "$ID" == "ubuntu" ]; then
    sudo apt update
    sudo apt upgrade -y
    for i in $BASEPACKAGES; do
        sudo apt install -y --no-install-recommends "$i"
    done
    for i in $DEBIANPACKAGES; do
        sudo apt install -y --no-install-recommends "$i"
    done
    sudo apt autoclean -y
    sudo apt autoremove -y
elif [ "$ID" == "fedora" ] || [ "$ID" == "centos" ] || [ "$ID" == "rhel" ]; then
    sudo dnf update -y
    sudo dnf install -y "$BASEPACKAGES" || true
    sudo dnf install -y "$FEDORAPACKAGES" || true
elif [ "$ID" == "alpine" ]; then
    sudo apk update
    sudo apk add "$BASEPACKAGES"
    sudo apk add "$ALPINEPACKAGES"
elif [ "$ID" == "void" ]; then
    sudo xbps-install -Su -y "$BASEPACKAGES"
    sudo xbps-install -Su -y "$VOIDPACKAGES"
fi

# Setup Zsh
bash -c "$DOTFILES/setup_zsh.sh"

# Install Development tools
bash -c "$DOTFILES/setup_development.sh"

# Setup and install additional applications
bash -c "$DOTFILES/setup_apps.sh"

# Setup Tmux
bash -c "$DOTFILES/setup_tmux.sh"

# Add user to passwordless sudo
#sudo sed -i "%admin    ALL = (ALL) NOPASSWD:ALL"

echo ""
log "Linux Setup finished!" "$GREENUNDER"
echo ""
