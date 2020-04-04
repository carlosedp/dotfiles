#!/bin/bash

DOTFILES=$HOME/.dotfiles
cd $HOME

echo "Don't forget to install XCode or Developer tools"
echo "======================================================="
echo ""
echo "Testing if you have XCode or Developer tools already installed"
echo ""
# Test for XCode install
if [[ ! `which gcc` ]]; then
    echo "Xcode/Dev Tools not installed. Installing..."
    xcode-select --install
else
    echo "Dev Tools detected, installation will proceed in 2 seconds"
fi
echo ""
sleep 2

# Test if homebrew is installed
echo "Testing if you have Homebrew already installed"
echo ""
if [[ ! `which brew` ]]; then
    echo "Homebrew not installed, installing..."
    echo ""
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "Homebrew is installed, will update"
    echo ""
    brew update
fi
sleep 3

echo "Install brews"
echo "==================================="
echo ""
# Command line apps
brew bundle install --file $DOTFILES/Brewfile
# Mac apps
brew bundle install --file $DOTFILES/Brewfile-casks-store
echo ""
echo "done ..."
echo ""
sleep 1

# Install additional fonts
sudo cp $HOME/.dotfiles/fonts/* /Library/Fonts

# Install Go applications
bash -c $DOTFILES/go_apps.sh

# Setup dotfiles
bash -c $DOTFILES/setup_links.sh

# Setup Zsh
bash -c $DOTFILES/setup_zsh.sh

# Setup Tmux
bash -c $DOTFILES/setup_tmux.sh

# Setup OsX defaults
bash -c $DOTFILES/osx_prefs.sh

# Add TouchID authentication to Sudo
if [[ ! `grep "pam_tid.so" /etc/pam.d/sudo` ]]; then
    echo -e "auth       sufficient     pam_tid.so\n$(cat /etc/pam.d/sudo)" |sudo tee /etc/pam.d/sudo;
fi

# Add user to passwordless sudo
#sudo sed -i "%admin    ALL = (ALL) NOPASSWD:ALL"

echo "Setup finished!"
