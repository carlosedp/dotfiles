#------------------------------------------////
# Only for Mac OSX
#------------------------------------------////

alias brewupd='brew update && brew upgrade && brew cask upgrade && brew cleanup'
alias brewdeps='brew list -1 | while read cask; do echo -ne "\x1B[1;34m $cask \x1B[0m"; brew uses $cask --installed | awk '"'"'{printf(" %s ", $0)}'"'"'; echo ""; done'

# Use GNU utils as default
alias indent='gindent'
alias sed='gsed'
alias tar='gtar'
alias make='gmake'
alias grep='ggrep'
alias which='gwhich'

# Quicklook file. Depends on osx plugin from zsh oh-my-zsh
alias ql='quick-look'

alias cat='bat --italic-text=always -p --pager "less -rX"'

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Empty the Trash on all mounted volumes and the main HDD
# Also, clear Apple’s System Logs to improve shell startup speed
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

# Decode base64 string from the clipboard
alias clipdecode="pbpaste|base64 --decode"

# Flush Directory Service cache
alias flushdns="dscacheutil -flushcache && killall -HUP mDNSResponder"
