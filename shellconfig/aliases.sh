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
if ls --color >/dev/null 2>&1; then # GNU `ls`
  colorflag="--color"
else # OS X `ls`
  colorflag="-G"
fi

# Ls aliases
# Commented due to use of zsh-exa plugin
# alias ls='ls -hF ${colorflag}' # classify files in colour
# alias ll='ls -ltr'   # long list
# alias la='ls -lA'    # all but . and ..
alias exa='eza --color=always'
alias eza='eza --color=always'
alias ll='eza -lbF -smod' # long list
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
alias less='less -rX'  # raw control characters
alias whence='type -a' # where, of a sort

# Observability
alias sniffapp="lsof -i 4tcp"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""
alias top='top -c'
alias diskstat='watch -c -d -n 1 "sudo S_COLORS=always iostat -xmdzc -t 1 1"'
alias iotop='sudo iotop -oa'
alias vmstat='vmstat -Sm 1'
alias mpstat='watch -c -d -n 1 "sudo S_COLORS=always mpstat -P ALL"'
alias netuse='watch -c -d -n 1 "sudo S_COLORS=always sar -n DEV 0"'
alias diskuse='watch -c -d -n 1 "sudo S_COLORS=always sar -d 0"'

alias grep='grep --color=auto '
alias sudo='sudo '
alias p='ps aux | grep -v ]$'
alias hl='$HOME/.dotfiles/bin/highlight'

alias sc-dreload='sudo systemctl daemon-reload'

# Git aliases
alias gitchanges='find . -maxdepth 1 -mindepth 1 -type d -exec sh -c "(echo \"--------------- \n Repo: \"{} && cd {} && git status -s && echo)" \;'                                                                           # Show git status of all repos in current dir
alias gs='git s -u'                                                                                                                                                                                                           # Show status
alias gr='git remote -v'                                                                                                                                                                                                      # Show remotes
alias gcs='git commit -v -s'                                                                                                                                                                                                  # Commit verbose and sign
alias gtl='git log --tags -10 --simplify-by-decoration  --reverse --date=format:"%Y-%m-%d %H:%I:%S" --format=format:"%C(03)%>|(10)%h%C(reset)  %C(04)%ad%C(reset)  %C(green)%<(16,trunc)%an%C(reset)  %C(bold 1)%d%C(reset)"' # Show last 10 tags
alias gcns='git commit -v --no-edit -s --amend'                                                                                                                                                                               # Commit no edit, sign and amend
alias gstu='git stash --include-untracked'                                                                                                                                                                                    # Stash all files including untracked
alias gdm='git diff $(git rev-parse --abbrev-ref --symbolic-full-name @{u})...'                                                                                                                                               # Diff current branch with it's upstream

alias ansible-syntax='ansible-playbook --syntax-check -i "127.0.0.1,"'
alias elasticindex='watch -n 5 "curl -s \"http://elasticsearch.internal.carlosedp.com/_cat/nodes?v&s=name\"; echo \"\n\"; curl -s \"http://elasticsearch.internal.carlosedp.com/_cat/indices?v&s=index:desc\"|head -30"'

alias dis='docker images --format "{{.Size}}\t{{.Repository}}:{{.Tag}}\t{{.ID}}" | sort -h'
alias dc='docker-compose'
alias fl='footloose'
alias tm='tmux new -A -s mySession'
alias tma='tmate new -A -s mySession'
alias yaegi='rlwrap yaegi'
alias dot='cd $HOME/.dotfiles'
alias query-manifest='qi'
alias tree='tree --dirsfirst -F -A -C --gitignore -I "out|node_modules|vendor|build"'

alias ping='prettyping'
alias fuck='sudo $(fc -ln -1)'

alias zshupd='$HOME/.dotfiles/setup_zsh.sh'
alias aptupd='sudo apt update && sudo apt upgrade -y && sudo apt autoclean -y && sudo apt autoremove -y'
alias jtop='sudo jtop'

if [[ $(command -v bat) ]]; then
  alias cat="bat"
elif [[ $(command -v batcat) ]]; then
  alias cat="batcat"
else
  alias cat="bat"
fi

alias ic='it2copy'
alias ytdl='yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4"'
alias glow='glow -p'

# Golang
alias goupall='go get -u ./...'

# NPM
alias nig='npm install -g'
alias nlg='npm list -g'
alias nug='npm update -g'
