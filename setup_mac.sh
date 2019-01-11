#!/bin/bash

DOTFILES=$HOME/.dotfiles

# Ask admin pwd
sudo -v

echo "Don't forget to install XCode or Developer tools"
echo "======================================================="
echo ""
echo "(If not... Ctrl-C to cancel)"
echo ""
echo "Testing if you have XCode or Developer tools already installed"

cd ~/
# Test for XCode install
if [[ ! `which gcc` ]]; then
    echo "Xcode/Dev Tools not installed. Install and rerun this script."
    return 1
else
    echo "Dev Tools detected, installation will proceed in 2 seconds"
fi
echo ""
sleep 2

# Test if homebrew is installed
echo "Testing if you have Homebrew already installed"
if [[ ! `which brew` ]]; then
    echo "Homebrew not installed, installing..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "Homebrew is installed, will update"
    brew update
fi
sleep 3

echo "Install the rest of important brews"
echo "==================================="
# Install basic apps (git, wget, etc)
HOMEBREW_NO_AUTO_UPDATE=1
brew install \
    git \
    wget \
    ack \
    markdown \
    sshuttle \
    htop \
    jq \
    bat \
    prettyping \
    autojump \
    tree \
    hub \
    youtube-dl

# Cleanup old installs
brew update
brew upgrade
brew cleanup
echo ""
echo "done ... Installing extra brews"
sleep 3

# Install lunchy to ease usage of launchctl
#sudo gem install lunchy

# Mount / drive with noatime
#sudo cp com.noatime.plist /Library/LaunchDaemons/com.noatime.plist
#sudo chown root:wheel /Library/LaunchDaemons/com.noatime.plist
#sudo chmod 644 /Library/LaunchDaemons/com.noatime.plist

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

# Setup dotfiles
bash -c $DOTFILES/set_links.sh

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

# Docker and Kubernetes packages
brew install kubernetes-cli docker-completion
#Kail (log tail)
brew tap boz/repo
brew install boz/repo/kail

# Dive, container image inspection tool
brew tap wagoodman/dive
brew install dive

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
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting
brew install zsh-completions

# Editor and Terminal
echo "Installing iTerm2, VSCode and fonts/utilities"
brew cask install iterm2
brew cask install visual-studio-code
brew tap homebrew/cask-fonts
brew cask install font-fira-code
brew cask instal kdiff3
brew cask install open-in-code

# Ansible and sshpass
brew install ansible
brew install hudochenkov/sshpass/sshpass

# Markdown extensions
brew cask install qlmarkdown
brew cask install qlcolorcode

# Quicklook extensions
brew cask install quicklook-json
brew cask install qlstephen

# Add TouchID authentication to Sudo
if [[ ! `grep "pam_tid.so" /etc/pam.d/sudo` ]]; then
    echo -e "auth       sufficient     pam_tid.so\n$(cat /etc/pam.d/sudo)" |sudo tee /etc/pam.d/sudo;
fi

echo "Setup finished!"