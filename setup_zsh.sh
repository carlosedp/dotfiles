#!/bin/bash

# Check pre-reqs
if [[ $(command -v git) == "" ]] || [[ $(command -v curl) == "" ]]; then
    echo "Curl or git not installed..."
    exit 1
fi

echo "Starting Zsh setup"
echo ""
DOTFILES=$HOME/.dotfiles

sudo -v

if [ $(uname) == "Darwin" ]; then
    echo "Checking if Homebrew is installed"
    echo ""
    if [[ $(command -v brew) == "" ]]; then
        echo "Homebrew not installed, installing..."
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        echo ""
    fi

     # Install Zsh on Mac
    if [ -x "$(command zsh --version)" ] 2> /dev/null 2>&1; then
        echo "Zsh not installed, installing..."
        brew install zsh
        sudo chsh -s /usr/local/bin/zsh $USER
    fi
else
    # Install Zsh on Linux
    if [ $(cat /etc/os-release | grep -i "ID=debian") ] || [ $(cat /etc/os-release | grep -i "ID=ubuntu") ]; then
        sudo apt update
        sudo apt install -y zsh
        ZSH=`which zsh`
        sudo chsh -s $ZSH $USER
    fi
    if [ $(cat /etc/os-release | grep -i "ID=fedora") ]; then
        sudo dnf install -y zsh
        ZSH=`which zsh`
        sudo usermod --shell $ZSH $USER
    fi
fi

echo "Get dotfiles"
if [[ ! -d "$DOTFILES" ]]; then
    git clone https://github.com/carlosedp/dotfiles.git $DOTFILES
else
    echo "You already have the dotfiles, updating..."
    pushd $DOTFILES; git pull; popd
fi

echo "Install oh-my-zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
else
    echo "You already have the oh-my-zsh, updating..."
    pushd $HOME/.oh-my-zsh; git pull; popd
fi

# Link .rc files
bash -c $DOTFILES/setup_links.sh

# Zsh plugins
ZSH_CUSTOM=$HOME/.oh-my-zsh/custom

echo "Installing spaceship prompt..."
if [[ ! -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]]; then
    git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
    ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
else
    echo "You already have spaceship, updating..."
    pushd $ZSH_CUSTOM/themes/spaceship-prompt; git pull; popd
fi

echo "Installing zsh-iterm-touchbar plugin..."
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-iterm-touchbar" ]]; then
    git clone https://github.com/carlosedp/zsh-iterm-touchbar.git "$ZSH_CUSTOM/plugins/zsh-iterm-touchbar"
else
    echo "You already have zsh-iterm-touchbar, updating..."
    pushd $ZSH_CUSTOM/plugins/zsh-iterm-touchbar; git pull; popd
fi

echo "Installing autoupdate-oh-my-zsh-plugins..."
if [[ ! -d "$ZSH_CUSTOM/plugins/autoupdate" ]]; then
    git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins "$ZSH_CUSTOM/plugins/autoupdate"
else
    echo "You already have autoupdate-oh-my-zsh-plugins, updating..."
    pushd $ZSH_CUSTOM/plugins/autoupdate; git pull; popd
fi

echo "Installing zsh-autosuggestions..."
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "You already have zsh-autosuggestions, updating..."
    pushd $ZSH_CUSTOM/plugins/zsh-autosuggestions; git pull; popd
fi

echo "Installing zsh-syntax-highlighting..."
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "You already have zsh-syntax-highlighting, updating..."
    pushd $ZSH_CUSTOM/plugins/zsh-syntax-highlighting; git pull; popd
fi

echo "Installing zsh-completions..."
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
else
    echo "You already have zsh-completions, updating..."
    pushd $ZSH_CUSTOM/plugins/zsh-completions; git pull; popd
fi
