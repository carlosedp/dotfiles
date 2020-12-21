#!/usr/bin/env bash
set -euo pipefail

# Load utility functions
source utils.sh

log "Starting Tmux setup" $GREENUNDER
echo ""
DOTFILES=$HOME/.dotfiles
cd $HOME

tmuxcommand=tmux

# Load Linux distro info
if [ $(uname -s) != "Darwin" ]; then
    if [ -f /etc/os-release ]; then
        source /etc/os-release
    else
        log "ERROR: I need the file /etc/os-release to determine the Linux distribution..." $RED
        exit 1
    fi
fi

if [ ! "$(command -v $tmuxcommand )" ] 2> /dev/null 2>&1; then
    if [ $(uname -s) == "Darwin" ]; then
        log "> Checking if Homebrew is installed" $GREEN
        echo ""
        if [[ $(command -v brew) == "" ]]; then
            log "Homebrew not installed, installing..." $YELLOW
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            echo ""
        fi

        # Install tmux on Mac
        log "$tmuxcommand not installed, installing..." YELLOW
        brew install $tmuxcommand
    else
        # Install tmux on Linux
        if [ $ID == "debian" ] || [ $ID == "ubuntu" ]; then
            sudo apt update
            sudo apt install --no-install-recommends -y $tmuxcommand
        elif [ $ID == "fedora" ] || [ $ID == "centos" ] || [ $ID == "rhel" ]; then
            sudo dnf install -y $tmuxcommand
        elif [ $ID == "alpine" ]; then
            sudo apk add $tmuxcommand
        elif [ $ID == "void" ]; then
            sudo xbps-install -Su $tmuxcommand
        else
            log "ERROR: Your distro is not supported, install tmux manually." $RED
            exit 1
        fi
    fi
fi

log "Get dotfiles" $GREEN
cloneorpull https://github.com/carlosedp/dotfiles.git $DOTFILES

# Link .rc files
bash -c $DOTFILES/setup_links.sh

echo "Install .tmux"
cloneorpull https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

log "Tmux setup finished." $GREENUNDER