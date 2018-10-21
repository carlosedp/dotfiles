

DOTFILES=~/.dotfiles

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
    echo "Dev Tools detected, installation will proceed in 4 seconds"
fi
echo ""
sleep 4

# Test if homebrew is installed
echo "Testing if you have Homebrew already installed"
if [[ ! `which brew` ]]; then
    echo "Homebrew not installed, installing..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "Homebrew is installed, will update"
fi
echo "Update homebrew packages"
brew update
sleep 3

echo "Install the rest of important brews"
echo "==================================="
# Install basic apps (git, wget, etc)

brew install \
    git \
    wget \
    ack \
    markdown \
    zsh \
    sshuttle \
    htop \
    zsh-completions \
    jq \
    bat \
    prettyping \
    autojump \
    tree

chsh -s /bin/zsh

# Cleanup old installs
brew cleanup
echo ""
echo "done ... Installing extra brews"
sleep 3

# Install lunchy to ease usage of launchctl
#sudo gem install lunchy

# Mount / drive with noatime
sudo cp com.noatime.plist /Library/LaunchDaemons/com.noatime.plist
sudo chown root:wheel /Library/LaunchDaemons/com.noatime.plist
sudo chmod 644 /Library/LaunchDaemons/com.noatime.plist

echo "Get dotfiles"
git clone https://github.com/carlosedp/dotfiles.git $DOTFILES

echo "Install oh-my-zsh"
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

echo "Install zsh plugins"
git clone https://github.com/carlosedp/zsh-iterm-touchbar.git ~/.oh-my-zsh/custom/plugins/zsh-iterm-touchbar

# Setup dotfiles
sh $DOTFILES/set_links.sh

# Setup OsX defaults
sh $DOTFILES/osx_prefs.sh
