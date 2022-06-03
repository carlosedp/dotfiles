#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

# Load utility functions
source "$HOME/.dotfiles/utils.sh"

log "Setup MacOS..." "$GREENUNDER"

DOTFILES="$HOME/.dotfiles"
cd "$HOME"

log "Checking if macOS is up to date..." "$GREEN"
if [[ "$(sudo softwareupdate -l 2>&1)" != *"No new software available"* ]]; then
    log "> Updating macOS" "$GREEN"
    sudo softwareupdate -i -a
    log "> Reboot your machine now and run this script again afterwards." "$YELLOW"
    exit 0
else
    log "> This MacOS is up to date." "$GREEN"
fi

log "Testing if you have XCode or Developer tools already installed" "$GREEN"
echo ""
# Test for XCode install
if [[ ! $(which gcc) ]]; then
    log "> Xcode/Dev Tools not installed. Installing..." "$YELLOW"
    xcode-select --install
else
    log "> Dev Tools detected, installation will proceed in 2 seconds" "$GREEN"
    echo ""
fi
sleep 2

# Test if homebrew is installed
log "Testing if you have Homebrew already installed" "$GREEN"
echo ""
if [[ ! $(which brew) ]]; then
    log "> Homebrew not installed, installing..." "$YELLOW"
    echo ""
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
    log "> Homebrew is installed, will update" "$GREEN"
    echo ""
    brew update
    brew upgrade
    brew upgrade --cask
    brew cleanup
fi
brew analytics off
sleep 2

log "Install brews" "$GREEN"
log "===================================" "$GREEN"
echo ""
# Command line apps
brew bundle install --file "$DOTFILES/mac/Brewfile"
# Mac apps (do not fail)
brew bundle install --file "$DOTFILES/mac/Brewfile-casks-store" || true
echo ""
log "Brew install finished..." "$GREEN"
echo ""
sleep 1

# Install additional fonts
for F in "$HOME"/.dotfiles/fonts/*.tar.gz; do sudo tar vxf "$F" -C /Library/Fonts; done

# Setup dotfiles
bash -c "$DOTFILES/setup_links.sh"

# Install Development tools
bash -c "$DOTFILES/setup_development.sh"

# Setup Zsh
bash -c "$DOTFILES/setup_zsh.sh"

# Setup and install additional applications
bash -c "$DOTFILES/setup_apps.sh"

# Setup Tmux
bash -c "$DOTFILES/setup_tmux.sh"

# Setup OsX defaults
bash -c "$DOTFILES/mac/osx_prefs.sh"


# Add TouchID authentication to Sudo
if ! grep -q "pam_tid.so" /etc/pam.d/sudo; then
    echo -e "auth       sufficient     pam_tid.so\n$(cat /etc/pam.d/sudo)" |sudo tee /etc/pam.d/sudo;
fi

log "Setup finished!" "$GREENUNDER"
