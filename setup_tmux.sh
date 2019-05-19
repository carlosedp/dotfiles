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

# Install if on Mac
if [ `uname -s` = 'Darwin' ]; then
    echo "Checking if Homebrew is installed"
    echo ""
    if [[ $(command -v brew) == "" ]]; then
        echo "Homebrew not installed, installing..."
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        echo ""
        exit 1
    fi

    if [ -x "$(command tmux -V)" ] 2> /dev/null 2>&1; then
        echo "Tmux not installed, installing..."
        sudo -v
        brew install tmux
    fi
fi

if [ -x "$(command tmux -V)" ] 2> /dev/null 2>&1; then
    echo "Tmux not installed, install with your package manager"
    exit 1
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
