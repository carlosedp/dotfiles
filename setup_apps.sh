#!/usr/bin/env bash
set -euo pipefail

# App configs

## VSCode settings sync
code --install-extension Shan.code-settings-sync

## Limechat settings
mkdir -p $HOME/Library/Application\ Support/net.limechat.LimeChat-AppStore/Themes
cp ./themes/Limechat-Choco/* $HOME/Library/Application\ Support/net.limechat.LimeChat-AppStore/Themes