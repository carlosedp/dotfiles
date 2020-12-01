#!/usr/bin/env bash

DOTFILES=$HOME/.dotfiles
cd $HOME

BASEPACKAGES="sudo curl wget git file dbus bc bash-completion hdparm sysstat less vim iptables ipset pciutils iperf3 net-tools jq haveged htop zsh tmux autojump neofetch lshw iotop ripgrep rsync tree"
DEBIANPACKAGES="openssh-client openssh-server locales ack-grep nfs-common apt-utils build-essential lsb-release telnet xz-utils apt-rdepends"
FEDORAPACKAGES="openssh-client openssh-server ack nfs-utils @development-tools which lsb-release telnet xz"
ALPINEPACKAGES="openssh-client openssh-server ack nfs-utils build-base xz"
VOIDPACKAGES="base-devel openssh inetutils-telnet xz"

# Install Linux packages
source /etc/os-release
if [ $ID == "debian" ] || [ $ID == "ubuntu" ]; then
    sudo apt update
    sudo apt upgrade -y
    for i in $BASEPACKAGES; do
        sudo apt install -y --no-install-recommends $i
    done
    for i in $DEBIANPACKAGES; do
        sudo apt install -y --no-install-recommends $i
    done
elif [ $ID == "fedora" ] || [ $ID == "centos" ]; then
    sudo dnf update -y
    sudo dnf install -y $BASEPACKAGES
    sudo dnf install -y $FEDORAPACKAGES
elif [ $ID == "alpine" ]; then
    sudo apk update
    sudo apk add $BASEPACKAGES
    sudo apk add $ALPINEPACKAGES
elif [ $ID == "void" ]; then
    sudo xbps-install -Su -y $BASEPACKAGES
    sudo xbps-install -Su -y $VOIDPACKAGES
fi

# Setup dotfiles
bash -c $DOTFILES/setup_links.sh

# Setup Zsh
bash -c $DOTFILES/setup_zsh.sh

# Install Development tools
bash -c $DOTFILES/setup_development.sh

# Setup Tmux
bash -c $DOTFILES/setup_tmux.sh

# Add user to passwordless sudo
#sudo sed -i "%admin    ALL = (ALL) NOPASSWD:ALL"

echo "Setup finished!"
