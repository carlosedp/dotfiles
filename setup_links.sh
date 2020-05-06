#!/bin/bash

# Settings
sync_folder="$HOME/Google Drive"

echo "Setting links to dotfiles on user home dir: $HOME"

create_link() {
  origin=$1
  dest=$2
  echo Linking origin file \"$origin\" to destination \"$dest\"

  if [[ -f "$dest" || -d "$dest" ]] && [ ! -L "$dest" ]; then
      echo "Destination ($dest) already exists. Renaming to $dest-old"
      mv "$dest" "$dest-old"
  fi
  ln -sfn "$origin" "$dest"
}

# Link .rc files
for FILE in $HOME/.dotfiles/rc/*
do
  create_link $FILE ~/.$(basename $FILE)
done

# Link SSH keys
if [[ ! -d "$HOME/.ssh" ]] && [[ -d "$sync_folder/SSH_Keys" ]]; then
    ln -sfn "$sync_folder/SSH_Keys" $HOME/.ssh
fi

# List of settings to be syncd between computers. Separated by spaces.

# Settings from $HOME/Library/Application Support
application_support_settings='2fa'

if [ $(uname) == "Darwin" ]; then
  # Link private settings to ~/Library/Application Support
  for X in $application_support_settings
  do
    if [[ ! -d "$HOME/Library/Application Support/$X" ]]; then
        create_link "$sync_folder/Configs/$X" "$HOME/Library/Application Support/$X"
    fi
  done

  # Link workflows from ~/Library/Services/
  for X in $(ls "$sync_folder/Configs/automator/")
  do
    create_link "$sync_folder/Configs/automator/"$X "$HOME/Library/Services/$X"
  done

  # Link preferences from ~/Library/Preferences/
  for X in $(ls "$HOME/.dotfiles/mac/configs/")
  do
    create_link "$HOME/.dotfiles/mac/configs/$X" "$HOME/Library/Preferences/$X"
  done

fi
