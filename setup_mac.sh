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

echo "Install the rest of important brews"
echo "==================================="
echo ""
# Install basic apps (git, wget, etc)
HOMEBREW_NO_AUTO_UPDATE=1
brew install \
    git \
    hub \
    wget \
    ack \
    markdown \
    sshuttle \
    htop \
    jq \
    bat \
    autojump \
    tree \
    youtube-dl \
    gawk \
    rlwrap \
    xz \
    neofetch \
    gnu-tar

# Cleanup old installs
brew update
brew upgrade
brew cleanup
echo ""
echo "done ... Installing extra brews"
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

# Brew and additional commands
brew tap buo/cask-upgrade
brew tap beeftornado/rmtree

# Macbook pro key repeats fix
brew cask install unshaky

# My taps
brew tap carlosedp/tap
brew install sshoot

# Docker
brew cask install docker

# Docker and Kubernetes packages
brew install kubernetes-cli \
             docker-completion \
             kubectx

# Footloose (https://github.com/weaveworks/footloose/)
brew tap weaveworks/tap
brew install weaveworks/tap/footloose

# Kubernetes Logging
brew install stern
brew install peco

# Dive, container image inspection tool
brew tap wagoodman/dive
brew install dive

# Editor and Terminal
echo "Installing iTerm2, VSCode and fonts/utilities"
echo ""
brew cask install iterm2
brew cask install visual-studio-code
brew tap homebrew/cask-fonts
brew cask install font-firacode-nerd-font
brew cask instal kdiff3
brew cask install open-in-code

# Notes
brew cask install joplin

# Ansible and sshpass
brew install ansible
brew install hudochenkov/sshpass/sshpass

# Markdown extensions
brew cask install qlmarkdown
brew cask install qlcolorcode

# Quicklook extensions
brew cask install quicklook-json
brew cask install qlstephen

# Install Programming languages
brew install python
brew install go

# Add TouchID authentication to Sudo
if [[ ! `grep "pam_tid.so" /etc/pam.d/sudo` ]]; then
    echo -e "auth       sufficient     pam_tid.so\n$(cat /etc/pam.d/sudo)" |sudo tee /etc/pam.d/sudo;
fi

# Add user to passwordless sudo
#sudo sed -i "%admin    ALL = (ALL) NOPASSWD:ALL"

echo "Setup finished!"
