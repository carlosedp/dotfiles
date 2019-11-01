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
brew bundle install
echo ""
echo "done ..."
echo ""
sleep 1

# Install lunchy to ease usage of launchctl
# sudo gem install lunchy

# Install prettyping
curl https://raw.githubusercontent.com/carlosedp/prettyping/master/prettyping -o /usr/local/bin/prettyping

# Mount / drive with noatime
#sudo cp com.noatime.plist /Library/LaunchDaemons/com.noatime.plist
#sudo chown root:wheel /Library/LaunchDaemons/com.noatime.plist
#sudo chmod 644 /Library/LaunchDaemons/com.noatime.plist

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
