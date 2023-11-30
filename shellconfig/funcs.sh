#!/usr/bin/env bash

# Functions when required functionality won't work with an alias

# Updates all packages
updall() {
    if [ -x "$(command -v brew)" ] >/dev/null 2>&1; then
        brewupd
    fi
    if [ "$(uname -s)" == "Linux" ]; then
        if [ -x "$(command -v apt)" ] >/dev/null 2>&1; then
            aptupd
        fi
        if [ -x "$(command -v dnf)" ] >/dev/null 2>&1; then
            dnf upgrade
        fi
    fi
    if [ -x "$(command -v cs)" ] >/dev/null 2>&1; then
        cs update
    fi
    if [ -x "$(command -v npm)" ] >/dev/null 2>&1; then
        npm -g update
    fi
    zshupd
    bash -c "$HOME/.dotfiles/setup_apps.sh"
}

timezsh() {
    shell=${1-$SHELL}
    for _ in $(seq 1 4); do /usr/bin/time "$shell" -i -c exit; done
}

function update() {
    if [ "$(uname -s)" == "Linux" ]; then
        bash -c "$HOME/.dotfiles/setup_linux.sh"
    elif [ "$(uname -s)" == "Darwin" ]; then
        bash -c "$HOME/.dotfiles/setup_mac.sh"
    fi
}

# Generate a scp command to copy files between hosts
function scppath() {
    if [ "$#" -ne 1 ]; then
        echo "Illegal number of parameters. Call function with file name."
        echo "E.g. $0 myfile"
        return
    fi
    if [ "$(uname -s)" == "Linux" ]; then
        IP=$(hostname -I | awk '{print $1}')
    elif [ "$(uname -s)" == "Darwin" ]; then
        IP=$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}' | head -1)
    fi

    echo "$USER"@"$IP":"$(readlink -f "$1")"
}

# Quickly find files by name
function f() {
    if [ "$#" -ne 1 ]; then
        echo "Illegal number of parameters. Call function with file name or wildcard."
        echo "E.g. $0 *.pdf"
        return
    fi
    name=$1
    shift
    find . -iname "*$name*" "$@"
}

# Call journalctl for process or all if no arguments
function jo() {
    if [[ "$1" != "" ]]; then
        sudo journalctl -xef -u "$1"
    else
        sudo journalctl -xef
    fi
}

# Generate a patch email from git commits
function gpatch() {
    if [[ "$1" != "" ]]; then
        git format-patch HEAD~"$1"
    else
        git format-patch HEAD~
    fi
}

# Send patch file with git
function gsendpatch() {
    echo 'If replying to an existing message, add "--in-reply-to messageIDfromMessage@somehostname.com" param'
    patch=$1
    shift
    git send-email \
        --cc-cmd="./scripts/get_maintainer.pl --norolestats $patch" \
        "$@" "$patch"
}

# Query Docker image manifest
function qi() {
    if [ "$#" -lt 1 ]; then
        echo "Illegal number of parameters. Call function with image name."
        echo "E.g. $0 repo/image"
        return
    fi
    echo "Querying image $1"
    if docker manifest inspect "$1" | jq -r '.manifests[] | [.platform.os, .platform.architecture] |@csv' 2>/dev/null | sed -E 's/\"(.*)\",\"(.*)\"/- \1\/\2/g' | grep -v '^/$'; then
        echo "$OUT"
    else
        echo "Image does not have a multiarch manifest."
    fi
}

# Execute ripgrep output thru pager
function rg() {
    command rg -p "$@" | less -FRX
}

# Install latest Golang. Replaces current one on /usr/local/go
function install_golang() {
    function install() {
        if ldd --version 2>&1 | grep -i musl >/dev/null; then
            echo "ERROR: Distro not supported for Go."
            return 1
        fi
        declare -A ARCH=([x86_64]=amd64 [aarch64]=arm64 [armv7l]=arm [ppc64le]=ppc64le [s390x]=s390x)
        pushd /tmp >/dev/null || return
        FILE=$(curl -sL https://golang.org/dl/?mode=json | grep -E 'go[0-9\.]+' | sed 's/.*\(go.*\.tar\.gz\).*/\1/' | sort -n | grep -i "$(uname -s)" | grep tar | grep "${ARCH[$(uname -m)]}" | tail -1)
        CURRENT_VERSION=$(go version | grep -Po "go[0-9]\.[0-9]+\.[0-9]+") >/dev/null 2>&1
        NEW_VERSION=$(echo "$FILE" | grep -Po "go[0-9]\.[0-9]+\.[0-9]+")
        if [ "$CURRENT_VERSION" == "$NEW_VERSION" ]; then
            echo "Go version $CURRENT_VERSION already installed."
            return 0
        fi
        echo "Installing $FILE"
        curl -sL https://dl.google.com/go/"$FILE" -o "$FILE"
        sudo rm -rf /usr/local/go
        sudo tar xf "$FILE" -C /usr/local/ 2>/dev/null
        rm -rf "$FILE"
        popd >/dev/null || return
    }
    install && echo "Installed $FILE" || echo "Error installing Go"
}

# Searches SSH hosts thru fzf and connects to it
function ss() {
    filter=${1:-"."}
    target=$(grep -E -o "Host (\b.+\b)" ~/.ssh/config | awk '{print $2}' | grep "$filter" | fzf -e)
    if [ "$target" ]; then
        echo "Remoting into: $target"
        ssh "$target"
    fi
}

# Return latest Github release
# Usage: lgr <owner/repo> <additional_grep_filter>
lgr() {
    if [ "$#" -lt 1 ]; then
        echo "Illegal number of parameters. Call function with author/repo."
        echo "E.g. $0 author/repository"
        return
    fi
    repo=https://api.github.com/repos/${1}/releases/latest

    # Additional grep filter
    FILTER=""
    if [ -n "${3+set}" ]; then
        FILTER="$3"
    fi

    VERSION=$(curl -s "${repo}" | grep "tag_name" | cut -d '"' -f 4 | grep "${FILTER}")
    echo "${VERSION}"
}

# Download Github release
# Usage: dlgr <owner/repo> <output_name> <additional_grep_filter>
dlgr() {
    if [ "$#" -lt 1 ]; then
        echo "Illegal number of parameters. Call function with author/repo."
        echo "E.g. $0 author/repository"
        return
    fi
    repo=https://api.github.com/repos/${1}/releases/latest

    # Additional grep filter
    FILTER=""
    if [ -n "${3+set}" ]; then
        FILTER="$3"
    fi

    URL=$(curl -s "${repo}" | grep "$(uname | tr LD ld)" | grep "$(uname -m)" | grep "browser_download_url" | cut -d '"' -f 4 | grep "${FILTER}" | grep -v "\(sha256\|md5\|sha1\)")
    FILENAME="$(echo "${URL}" | rev | cut -d/ -f1 | rev)"
    OUT="${FILENAME}"
    if [ "${URL}" ]; then
        if [ -n "${2+set}" ]; then
            if [[ "${FILENAME}" == *gz ]]; then
                OUT=$(echo "$2" | awk '{$1=$1};1').gz
            else
                OUT=$(echo "$2" | awk '{$1=$1};1')
            fi
        fi
        curl -s -o "${OUT}" -OL "${URL}"
    else
        return 1
    fi
    if [[ "${FILENAME}" == *gz ]]; then
        gzip -d "${OUT}"
    fi
}

# Checkout last tag
gcolast() {
    LASTTAG=git describe --tags "$(git rev-list --tags --max-count=1)"
    git checkout "$LASTTAG"
}

# Load GTKWave in the background
gtkw() {
    BIN=/Applications/gtkwave.app/Contents/Resources/bin/gtkwave
    if test -f "./GTKwave/gtkwave.tcl"; then
        $BIN -S "./GTKwave/gtkwave.tcl" "$@" &
    elif test -f "$HOME/.dotfiles/rc/gtkwave.tcl"; then
        $BIN -S "$HOME/.dotfiles/rc/gtkwave.tcl" "$@" &
    else
        $BIN "$@" &
    fi
}

gtkwave() {
    BIN=/Applications/gtkwave.app/Contents/Resources/bin/gtkwave
    if test -f "./GTKwave/GTKWave.gtkw"; then
        $BIN "$@" "./GTKwave/GTKWave.gtkw" &
    else
        $BIN "$@" &
    fi
}

# Find the completion function
completion() {
    functions $_comps[${1}]
}

# Reload completion for command
reloadcomp() {
    unfunction "_${1}" && autoload -U "_${1}"
}

# Run silicon with code from clipboard. Puts image into clibboard
# Parameter 1 is the highlight language
siclip() {
    silicon --from-clipboard -l "${1:-bash}" --to-clipboard
}

# Git diff with Delta side-by-side
gdd() {
    preview=("git diff $@ --color=always -- {-1} | delta --side-by-side --width ${FZF_PREVIEW_COLUMNS-$COLUMNS}")
    git diff "$@" --name-only | fzf -m --ansi --height 100% --preview-window='up:75%' --cycle --reverse --exact --border --preview "${preview[@]}"
}

# Trap signals from command on $1 and run command $2 on exit
trapexit() {
    echo "Running command \"${1}\" and on exit (Ctrl+C), will run \"${2}\""
    bash -c "trap '${2}' SIGINT SIGTERM EXIT; ${1}"
}

addpath() {
    echo "Adding \"${1}\" to PATH"
    export PATH="${1}":$PATH
}

# Create a git annotated tag
gt() {
    if [ "$#" -lt 2 ]; then
        echo "Illegal number of parameters. Call function with tag name and a description."
        echo "E.g. $0 v1.0.0 My tag description"
        echo "Listing last 10 tags:"
        git log -n 10 --no-walk --tags --simplify-by-decoration --date=format:"%Y-%m-%d %H:%I:%S" --format=format:"%C(03)%>|(10)%h%C(reset)  %C(04)%ad%C(reset)  %C(bold 1)%<(25,trunc)%d%C(reset)  %C(green)%<(16,trunc)%an%C(reset)  %C(white)%s%C(reset)"
        return
    fi
    VER=$1
    shift
    DESC="$*"
    git tag -a "$VER" -m "$VER - $DESC"
}

# Push latest tag to remote
gtp() {
    # Ask if user wants to push to remote
    TAG=$(git describe --tags --abbrev=0)
    REMOTE=${1:-$(git remote | grep -v upstream | head -1)}
    echo "Push tag $TAG to remote $REMOTE? [y/n] "
    echo -n ">"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        git push "$REMOTE" "$TAG"
    fi
}
