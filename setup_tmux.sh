#!/usr/bin/env bash

echo "Starting Tmux setup"
echo ""
DOTFILES=$HOME/.dotfiles
pushd $HOME

tmuxcommand=tmux

# Load Linux distro info
if [ $(uname -s) != "Darwin" ]; then
    if [ -f /etc/os-release ]; then
        source /etc/os-release
    else
        log "ERROR: I need the file /etc/os-release to determine the Linux distribution..."
        exit 1
    fi
fi

if [ ! "$(command -v $tmuxcommand )" ] 2> /dev/null 2>&1; then
    if [ $(uname -s) == "Darwin" ]; then
        echo "Checking if Homebrew is installed"
        echo ""
        if [[ $(command -v brew) == "" ]]; then
            echo "Homebrew not installed, installing..."
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            echo ""
        fi

        # Install tmux on Mac
        echo "$tmuxcommand not installed, installing..."
        brew install $tmuxcommand
    else
        # Install tmux on Linux
        if [ $ID == "debian" ] || [ $ID == "ubuntu" ]; then
            sudo apt update
            sudo apt install --no-install-recommends -y $tmuxcommand
        elif [ $ID == "fedora" ] || [ $ID == "centos" ]; then
            sudo dnf install -y $tmuxcommand
        elif [ $ID == "alpine" ]; then
            sudo apk add $tmuxcommand
        elif [ $ID == "void" ]; then
            sudo xbps-install -Su $tmuxcommand
        else
            echo "ERROR: Your distro is not supported, install tmux manually."
            exit 1
        fi
    fi
fi

echo "Get dotfiles"
if [[ ! -d "$DOTFILES" ]]; then
    git clone https://github.com/carlosedp/dotfiles.git $DOTFILES
else
    echo "You already have the dotfiles, updating..."
    pushd $DOTFILES; git pull; popd
fi

# Link .rc files
bash -c $DOTFILES/setup_links.sh

echo "Install .tmux"
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
else
    echo "You already have the .tmux, updating..."
    pushd $HOME/.tmux/plugins/tpm; git pull; popd
fi

