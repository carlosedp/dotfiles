#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

# Load utility functions
source "$HOME/.dotfiles/utils.sh"

log "Setup home links..." "$GREENUNDER"

# ------------------------------------------------------------------------------
# Settings
# ------------------------------------------------------------------------------
SYNC_FOLDER="$HOME/Google Drive/My Drive"

#-------------------------------------------------------------------------------
# Script start
# ------------------------------------------------------------------------------

if [ "$(uname -s)" == "Darwin" ] && [ ! -d "$SYNC_FOLDER" ]; then
  log "----------------------------------------------------------------" "$REDBOLD"
  log "Could not find the source for private files (Dropbox or GDrive)." "$REDBOLD"
  log "Adjust the setup_links.sh script or sync your files first." "$REDBOLD"
  log "Your source folder is currently set to $SYNC_FOLDER" "$REDBOLD"
  log "----------------------------------------------------------------" "$REDBOLD"
  echo ""
fi

log "Setting links to dotfiles on user home dir: $HOME" "$GREEN"

# Link .rc files
log "Linking .rc files" "$GREEN"
for FILE in "$HOME"/.dotfiles/rc/*; do
  createLink "$FILE" "${HOME}/.$(basename "$FILE")"
done

# Link private .config files
log "Linking private .config files" "$GREEN"
linkAll "$SYNC_FOLDER"/Configs/rc/config "$HOME"/.config

# Link SSH keys
log "Linking .ssh directory" "$GREEN"
createLink "$SYNC_FOLDER/Configs/SSH_Keys" "$HOME/.ssh"

# Link PGP keys
log "Linking .ssh directory" "$GREEN"
createLink "$SYNC_FOLDER/Configs/pgp-keys" "$HOME/.gnupg"

# Link 2fa keychain file
log "Linking 2fa keychain" "$GREEN"
createLink "$SYNC_FOLDER/Configs/2fa/keychain" "$HOME/.2fa"

# If running on Windows WSL, link Google drive for private settings
if [[ $(grep Microsoft /proc/version) ]]; then
  ln -sf /mnt/g ~/"Google Drive"
fi

# List of settings to be syncd between computers. Separated by spaces.
if [ "$(uname -s)" == "Darwin" ]; then
  ## Settings from $HOME/Library/Application Support
  log "Linking ~/Library/Application Support files" "$GREEN"
  linkAll "$SYNC_FOLDER"/Configs/AppSupport "$HOME/Library/Application Support"

  ## Link preferences from ~/Library/Preferences/
  # log "Linking ~/Library/Preferences files" "$GREEN"
  # linkAll "$SYNC_FOLDER"/Configs/Preferences "$HOME/Library/Preferences"

  ## Link workflows from ~/Library/Services/
  log "Linking ~/Library/Services (automator) files" "$GREEN"
  linkAll "$SYNC_FOLDER"/Configs/automator "$HOME/Library/Services"
fi

log "Setting links finished" "$GREENUNDER"
