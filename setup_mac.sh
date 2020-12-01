#!/usr/bin/env bash

DOTFILES=$HOME/.dotfiles
cd $HOME

echo "Checking if macOS is up to date..."
if [[ "$(sudo softwareupdate -l 2>&1)" != *"No new software available"* ]]; then
echo "Updating macOS"
sudo softwareupdate -i -a
echo "Reboot your machine now and run this script again afterwards."
exit 0
else
echo "This macOS is up to date."
fi

echo "Don't forget to install XCode or Developer tools"
echo "======================================================="
echo ""
echo "Testing if you have XCode or Developer tools already installed"
echo ""
# Test for XCode install
if [[ ! $(which gcc) ]]; then
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
if [[ ! $(which brew) ]]; then
    echo "Homebrew not installed, installing..."
    echo ""
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
    echo "Homebrew is installed, will update"
    echo ""
    brew update
fi
brew analytics off
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
for F in $HOME/.dotfiles/fonts/*.tar.gz; do sudo tar vxf $F -C /Library/Fonts; done

# Setup dotfiles
bash -c $DOTFILES/setup_links.sh

# Setup Zsh
bash -c $DOTFILES/setup_zsh.sh

# Install Development tools
bash -c $DOTFILES/setup_development.sh

# Setup Tmux
bash -c $DOTFILES/setup_tmux.sh

# Setup OsX defaults
bash -c $DOTFILES/osx_prefs.sh

# Setup application specific configs
bash -c $DOTFILES/setup_apps.sh

# Add TouchID authentication to Sudo
if [[ ! $(grep "pam_tid.so" /etc/pam.d/sudo) ]]; then
    echo -e "auth       sufficient     pam_tid.so\n$(cat /etc/pam.d/sudo)" |sudo tee /etc/pam.d/sudo;
fi

echo "Setup finished!"
