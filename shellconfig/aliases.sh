#!/usr/bin/env bash

# Generic Aliases

# Override problematic aliases
# alias -g P=''

# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
  colorflag="--color"
else # OS X `ls`
  colorflag="-G"
fi

# Ls aliases
alias ls='ls -hF ${colorflag}' # classify files in colour
alias ll='ls -ltr'   # long list
alias la='ls -lA'    # all but . and ..
alias lsd='ls -lhF ${colorflag} | grep --color=never "^d"'
alias l='ls -CF'

# Interactive operation...
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Default to human readable figures
alias df='df -h'
alias du='du -h'

# Misc :)
alias less='less -rX'                          # raw control characters
alias whence='type -a'                        # where, of a sort

alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

alias top='top -c'
#alias screen='screen -RR'
alias grep='grep --color=auto '
alias sudo='sudo '
alias p='ps aux | grep -v ]$'
alias hl='$HOME/.dotfiles/bin/highlight'

alias sc-dreload='sudo systemctl daemon-reload'

# Git aliases
alias gitchanges='find . -maxdepth 1 -mindepth 1 -type d -exec sh -c "(echo \"--------------- \n Repo: \"{} && cd {} && git status -s && echo)" \;'
alias gs='git s -u'
alias gr='git remote -v'
alias glo='git l'
alias gcs='git commit -v -s'
alias gt='git log --tags -10 --simplify-by-decoration  --reverse --date=format:"%Y-%m-%d %H:%I:%S" --format=format:"%C(03)%>|(10)%h%C(reset)  %C(04)%ad%C(reset)  %C(green)%<(16,trunc)%an%C(reset)  %C(bold 1)%d%C(reset)"'
alias gcns!='git commit -v --no-edit -s --amend'

alias ansible-syntax='ansible-playbook --syntax-check -i "127.0.0.1,"'
alias diskstat='watch -c -n 1 "sudo S_COLORS=always iostat -c -d -h -xy -m -t 1 1"'
alias iotop='sudo iotop -oa'

alias elasticindex='watch -n 5 "curl -s \"http://elasticsearch.internal.carlosedp.com/_cat/nodes?v&s=name\"; echo \"\n\"; curl -s \"http://elasticsearch.internal.carlosedp.com/_cat/indices?v&s=index:desc\"|head -30"'

alias zshupd='$HOME/.dotfiles/setup_zsh.sh'
alias dis='docker images --format "{{.Size}}\t{{.Repository}}:{{.Tag}}\t{{.ID}}" | sort -h'
alias dc='docker-compose'
alias fl='footloose'
alias tm='tmux new -A -s mySession'
alias tma='tmate new -A -s mySession'
alias yaegi='rlwrap yaegi'
alias dot='cd $HOME/.dotfiles'
alias query-manifest='qi'
alias tree='tree -I "out|node_modules|vendor|build"'

alias sniffapp="lsof -i 4tcp"
alias ping='prettyping'
alias fuck='sudo $(fc -ln -1)'
alias aptupd='sudo apt update && sudo apt upgrade -y && sudo apt autoclean -y && sudo apt autoremove -y'
alias jtop='sudo jtop'

if [[ ! $(command -v batcat) ]]; then
  alias cat='batcat --italic-text=always -p --pager "less -rX"'
fi

alias ic='it2copy'
