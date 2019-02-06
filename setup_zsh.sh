#!/bin/bash

# Create links for dotfiles
create_link() {
  origin=$1
  dest=$2
  echo Linking origin file \"$origin\" to destination \"$dest\"

  if [[ -f "$dest" || -d "$dest" ]] && [ ! -L "$dest" ]; then
      echo "Destination ($dest) already exists. Renaming to $dest-old"
      mv "$dest" "$dest-old"
  fi
  ln -sf "$origin" "$dest"
}

echo "Starting Zsh setup"
echo ""
DOTFILES=$HOME/.dotfiles

echo "Checking if Homebrew is installed"
echo ""
if [[ $(command -v brew) == "" ]]; then
    echo "Homebrew not installed, installing..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    echo ""
    exit 1
fi

if [ -x "$(command zsh --version)" ] 2> /dev/null 2>&1; then
    echo "Zsh not installed, installing..."
    sudo -v
    brew install zsh
    sudo chsh -s /usr/local/bin/zsh $USER
fi

echo "Get dotfiles"
if [[ ! -d "$DOTFILES" ]]; then
    git clone https://github.com/carlosedp/dotfiles.git $DOTFILES
else
    echo "You already have the dotfiles, updating..."
    pushd $DOTFILES; git pull; popd
fi

# Link .rc files
for FILE in $HOME/.dotfiles/rc/*
do
  create_link $FILE ~/.$(basename $FILE)
done

echo "Install oh-my-zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
else
    echo "You already have the oh-my-zsh, updating..."
    pushd $HOME/.oh-my-zsh; git pull; popd
fi

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

echo "Installing additional zsh plugins"
HOMEBREW_NO_AUTO_UPDATE=1
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting
brew install zsh-completions
brew update
brew upgrade