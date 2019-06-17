#!/bin/bash

#-Functions---------------------------------------------------------------------
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
#-------------------------------------------------------------------------------

echo "Starting Tmux setup"
echo ""
DOTFILES=$HOME/.dotfiles
pushd $HOME

if [ $(uname) == "Darwin" ]; then
    echo "Checking if Homebrew is installed"
    echo ""
    if [[ $(command -v brew) == "" ]]; then
        echo "Homebrew not installed, installing..."
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        echo ""
    fi

     # Install tmate on Mac
    if [ -x "$(command zsh --version)" ] 2> /dev/null 2>&1; then
        echo "Zsh not installed, installing..."
        brew install tmate
    fi
else
    # Install tmate on Linux
    if [ $(cat /etc/os-release | grep -i "ID=debian") ] || [ $(cat /etc/os-release | grep -i "ID=ubuntu") ]; then
        sudo apt update
        sudo apt install -y tmate
    fi
    if [ $(cat /etc/os-release | grep -i "ID=fedora") ]; then
        sudo dnf install -y tmate
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
for FILE in $HOME/.dotfiles/rc/*
do
  create_link $FILE ~/.$(basename $FILE)
done

echo "Install .tmux"
if [[ ! -d "$HOME/.tmux" ]]; then
    git clone https://github.com/gpakosz/.tmux
    ln -sf .tmux/.tmux.conf $HOME
else
    echo "You already have the .tmux, updating..."
    pushd $HOME/.tmux; git pull; popd
fi
