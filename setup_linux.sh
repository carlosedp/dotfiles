#!/bin/bash

DOTFILES=$HOME/.dotfiles
cd $HOME

BASEPACKAGES="sudo openssh-client openssh-server curl wget git file dbus bc bash-completion hdparm sysstat less vim iptables ipset pciutils iperf3 net-tools jq haveged htop zsh tmux autojump neofetch lshw telnet iotop"
DEBIANPACKAGES="locales ack-grep nfs-common apt-utils build-essential"
FEDORAPACKAGES="ack nfs-utils @development-tools"
ALPINEPACKAGES="ack nfs-utils build-base"

# Install Linux packages
if [ $(cat /etc/os-release | grep -i "ID=debian") ] || [ $(cat /etc/os-release | grep -i "ID=ubuntu") ]; then
    sudo apt update
    sudo apt upgrade
    sudo apt install -y $BASEPACKAGES
    sudo apt install -y $DEBIANPACKAGES
fi
if [ $(cat /etc/os-release | grep -i "ID=fedora") ]; then
    sudo dnf update
    sudo dnf upgrade
    sudo dnf install -y $BASEPACKAGES
    sudo dnf install -y $FEDORAPACKAGES
fi
if [ $(cat /etc/os-release | grep -i "ID=alpine") ]; then
    sudo apk update
    sudo apk add $BASEPACKAGES
    sudo apk add $ALPINEPACKAGES
fi

# Install Golang
GOVERSION=1.14.1
ARCH=$(uname -m)
case $ARCH in
    x86_64*)
        P_ARCH=amd64
        ;;
    aarch64*)
        P_ARCH=arm64
        ;;
    arm*hf)
        P_ARCH=armhf
        ;;
    *)
        echo "Install golang error: missing arch '${ARCH}'" >&2
        return 0
        ;;
esac
curl -sL https://dl.google.com/go/go$GOVERSION.linux-$P_ARCH.tar.gz | tar xf - -C /usr/local
export PATH=/usr/local/go/bin:$PATH
echo "Installed Go version $GOVERSION for $P_ARCH"
echo ""

# Install Go applications
bash -c $DOTFILES/go_apps.sh

# Setup dotfiles
bash -c $DOTFILES/setup_links.sh

# Setup Zsh
bash -c $DOTFILES/setup_zsh.sh

# Setup Tmux
bash -c $DOTFILES/setup_tmux.sh

# Add user to passwordless sudo
#sudo sed -i "%admin    ALL = (ALL) NOPASSWD:ALL"

echo "Setup finished!"
