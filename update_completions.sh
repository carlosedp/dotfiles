#!/usr/bin/env bash
set -euo pipefail

# Load utility functions
source "$HOME/.dotfiles/utils.sh"

log "Updating shell completions" "$GREENUNDER"

# BASH
## Generate kubectx and kubens completions
for X in kubectx kubens; do
    curl -sL -o "$HOME"/.dotfiles/completion/$X.bash https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/$X.bash
done

if [ -x "$(command -v kubectl)" ] > /dev/null 2>&1; then
        kubectl completion bash > "$HOME"/.dotfiles/completion/kubectl.bash
fi

if [ -x "$(command -v stern)" ] > /dev/null 2>&1; then
        stern --completion=bash > "$HOME"/.dotfiles/completion/stern.bash
fi

curl -sL -o "$HOME"/.dotfiles/completion/hub.bash https://github.com/github/hub/raw/master/etc/hub.bash_completion.sh

# gh (Github command line client)
if [ -x "$(command -v gh)" ] > /dev/null 2>&1; then
        gh completion -s bash > "$HOME"/.dotfiles/completion/gh.bash
fi

# ZSH
## Generate kubectx and kubens completions
for X in kubectx kubens; do
    curl -sL -o "$HOME"/.dotfiles/completion/_$X https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/$X.zsh
done

if [ -x "$(command -v kubectl)" ] > /dev/null 2>&1; then
        kubectl completion zsh > "$HOME"/.dotfiles/completion/_kubectl
fi

if [ -x "$(command -v stern)" ] > /dev/null 2>&1; then
        stern --completion=zsh > "$HOME"/.dotfiles/completion/_stern
fi

curl -sL -o "$HOME"/.dotfiles/completion/_hub https://github.com/github/hub/raw/master/etc/hub.zsh_completion

# gh (Github command line client)
if [ -x "$(command -v gh)" ] > /dev/null 2>&1; then
        gh completion -s zsh > "$HOME"/.dotfiles/completion/_gh
fi

# bloop
curl -s https://raw.githubusercontent.com/scalacenter/bloop/master/etc/zsh-completions -o "$HOME"/.dotfiles/completion/_bloop

# cs
if [ -x "$(command -v cs)" ] > /dev/null 2>&1; then
        cs --completions zsh > "$HOME"/.dotfiles/completion/_cs
fi

# scalafix
if [ -x "$(command -v scalafix)" ] > /dev/null 2>&1; then
        scalafix --zsh > "$HOME"/.dotfiles/completion/_scalafix
fi

# scalafmt
curl -s https://raw.githubusercontent.com/scalameta/scalafmt/master/bin/_scalafmt -o "$HOME"/.dotfiles/completion/_scalafmt

# Refresh completion
rm -f ~/.zcompdump

log "ZSH completions update finished." "$GREENUNDER"