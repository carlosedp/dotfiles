#!/bin/bash

echo "Starting Tmux setup"
echo ""
DOTFILES=$HOME/.dotfiles
pushd $HOME

tmuxcommand=tmux
if [ -x "$(command $tmuxcommand --version)" ] 2> /dev/null 2>&1; then
    if [ $(uname) == "Darwin" ]; then
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
        if [ $(cat /etc/os-release | grep -i "ID=debian") ] || [ $(cat /etc/os-release | grep -i "ID=ubuntu") ]; then
            sudo apt update
            sudo apt install -y $tmuxcommand
        fi
        if [ $(cat /etc/os-release | grep -i "ID=fedora") ]; then
            sudo dnf install -y $tmuxcommand
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

