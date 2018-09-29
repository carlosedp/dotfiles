#!/bin/bash

# Configure which dev tools should be installed. Set var to "1" to enable
PYTHON=0
NODEJS=0
RUBY=0
ERL=0

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
    ctags \
    ack \
    markdown \
    zsh \
    sshuttle \
    htop


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

echo "Install oh-my-zsh"
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

# Configure Sublimetext
#echo "Configuring Sublimetext..."
#mkdir -p ~/Library/Application\ Support/Sublime\ Text\ 3/Packages
#wget https://packagecontrol.io/Package%20Control.sublime-package ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages
#ln -sf ~/Dropbox/Configs/sublime/User ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
#sudo cp subl /usr/local/bin
#sleep 2

# Configure Unison
#echo "Configuring Unison..."
#mkdir -p /Users/carlosedp/Library/Application\ Support/Unison
#ln -sf  ~/Dropbox/Configs/unison/*.prf* /Users/carlosedp/Library/Application\ Support/Unison
#sleep 2

# Setup dotfiles
sh $DOTFILES/set_links.sh

# Setup OsX defaults
sh $DOTFILES/osx_prefs.sh

# Install Python Env
if [ $PYTHON -eq 1 ];
then
    echo "Install python.org package"
    mkdir .pythontemp
    mkdir -p $HOME/sandbox/virtualenvs
    cd .pythontemp
    curl -O http://python-distribute.org/distribute_setup.py
    sudo python distribute_setup.py
    sudo easy_install pip
    sudo pip install virtualenv
    sudo pip install virtualenvwrapper
    echo "Create new virtual envs using 'mkvirtualenv [NAME]'"
    echo "Add 'export WORKON_HOME=$HOME/sandbox/virtualenvs' to .bashrc"
    echo "Add 'source /Library/Frameworks/Python.framework/Versions/2.7/bin/virtualenvwrapper_bashrc' to .bashrc"
    cd ..
    rm -rf .pythontemp
fi

# Install Node.js Env
if [ $NODEJS -eq 1 ];
then
    git clone git://github.com/creationix/nvm.git ~/.nvm
    . ~/.nvm/nvm.sh
    nvm install stable
    nvm alias default stable
    nvm use stable
    npm install -g supervisor jsctags
fi

# Install Ruby Env
if [ $RUBY -eq 1 ];
then
    bash < <( curl http://rvm.beginrescueend.com/releases/rvm-install-head )
    source ~/.rvm/scripts/rvm
    rvm install 1.9.3
    rvm --default use 1.9.3
    rvm use 1.9.3
    # Install web dev apps
    #echo "Installing compass for sass"
    #sudo gem update --system
    #gem install rb-fsevent
    #gem install compass
fi




