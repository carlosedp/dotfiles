#!/usr/bin/env bash

#------------------------------------------////
# Only for Mac OSX
#------------------------------------------////

alias brewupd='brew update && brew upgrade && brew upgrade --cask && brew cleanup'
alias brewdeps='brew list --formula -1 | while read cask; do echo -ne "\x1B[1;34m $cask \x1B[0m"; brew uses $cask --installed | awk '"'"'{printf(" %s ", $0)}'"'"'; echo ""; done'

alias oping='sudo oping'
alias noping='sudo noping'

# Quicklook file. Depends on osx plugin from zsh oh-my-zsh
alias ql='quick-look'

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Empty the Trash on all mounted volumes and the main HDD
# Also, clear Apple’s System Logs to improve shell startup speed
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

# Decode base64 string from the clipboard
alias clipdecode="pbpaste|base64 --decode"

# Flush Directory Service cache
alias flushdns='dscacheutil -flushcache && ps aux|grep mDNSResponder |grep -v grep |awk '"'"'{print $2}'"'"' |xargs sudo kill -HUP'
