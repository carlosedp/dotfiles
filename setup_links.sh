#!/usr/bin/env bash
set -euo pipefail

# Load utility functions
source "$HOME/.dotfiles/utils.sh"

log "Setup home links..." "$GREENUNDER"

# ------------------------------------------------------------------------------
# Settings
# ------------------------------------------------------------------------------
SYNC_FOLDER="$HOME/Dropbox"

create_link() {
  origin=$1
  dest=$2
  log " > Linking origin file \"$origin\" to destination \"$dest\""
  if [[ ! -e "$origin" ]]; then
    log " >> Origin $origin does not exist" "$RED"
    return 1
  fi
  if [[ ! -e "$(dirname "$dest")" ]]; then
    log " >> Destination $dest does not exist, creating" "$YELLOW"
    mkdir -p "$(dirname "$dest")"
  fi
  if [[ -f "$dest" || -d "$dest" ]] && [ ! -L "$dest" ]; then
      log " > Destination ($dest) already exists. Renaming to $dest-old" "$YELLOW"
      mv "$dest" "$dest-old"
  fi
  ln -sfn "$origin" "$dest"
}

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
for FILE in "$HOME"/.dotfiles/rc/*
do
  create_link "$FILE" "${HOME}/.$(basename "$FILE")"
done

# Link private .config files
log "Linking private .config files" "$GREEN"
if [[ -d "$SYNC_FOLDER/Configs/rc/config" ]]; then
    for FILE in "$SYNC_FOLDER"/Configs/rc/config/*
    do
      create_link "$FILE" "${HOME}/.config/$(basename "$FILE")"
    done
fi

# Link SSH keys
log "Linking .ssh directory" "$GREEN"
if [[ -d "$SYNC_FOLDER/Configs/SSH_Keys" ]]; then
    create_link "$SYNC_FOLDER/Configs/SSH_Keys" "$HOME/.ssh"
fi

# Link PGP keys
log "Linking .ssh directory" "$GREEN"
if [[ -d "$SYNC_FOLDER/Configs/pgp-keys" ]]; then
    create_link "$SYNC_FOLDER/Configs/pgp-keys" "$HOME/.gnupg"
fi

# Link 2fa keychain file
log "Linking 2fa keychain" "$GREEN"
if [[ -f "$SYNC_FOLDER/Configs/2fa/keychain" ]]; then
  create_link "$SYNC_FOLDER/Configs/2fa/keychain" "$HOME/.2fa"
fi

# List of settings to be syncd between computers. Separated by spaces.
if [ "$(uname -s)" == "Darwin" ]; then
  ## Settings from $HOME/Library/Application Support
  log "Linking ~/Library/Application Support files" "$GREEN"
  for X in $(ls "$SYNC_FOLDER/Configs/AppSupport/")
  do
    create_link "$SYNC_FOLDER/Configs/AppSupport/$X" "$HOME/Library/Application Support/$X"
  done

  ## Link preferences from ~/Library/Preferences/
  log "Linking ~/Library/Preferences files" "$GREEN"
  for X in $(ls "$SYNC_FOLDER/Configs/Preferences/")
  do
    create_link "$SYNC_FOLDER/Configs/Preferences/$X" "$HOME/Library/Preferences/$X"
  done

  ## Link workflows from ~/Library/Services/
  log "Linking ~/Library/Services (automator) files" "$GREEN"
  for X in $(ls "$SYNC_FOLDER/Configs/automator/")
  do
    create_link "$SYNC_FOLDER/Configs/automator/"$X "$HOME/Library/Services/$X"
  done
fi

log "Setting links finished" $GREENUNDER
