#!/usr/bin/env bash

# App configs

## VSCode settings sync
code --install-extension Shan.code-settings-sync

## Limechat settings
mkdir -p $HOME/Library/Application\ Support/net.limechat.LimeChat-AppStore/Themes
cp $DOTFILES/themes/Limechat-Choco/*.{css,yaml} $HOME/Library/Application\ Support/net.limechat.LimeChat-AppStore/Themes
