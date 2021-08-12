#!/usr/bin/env bash

# Functions when required functionality won't work with an alias

function update() {
    if [ "$(uname -s)" == "Linux" ]; then
        bash -c "$HOME/.dotfiles/setup_linux.sh"
    elif [ "$(uname -s)" == "Darwin" ]; then
        bash -c "$HOME/.dotfiles/setup_mac.sh"
    fi
}

# Generate a scp command to copy files between hosts
function scppath () {
    if [ "$#" -ne 1 ]; then
        echo "Illegal number of parameters. Call function with file name."
        echo "E.g. $0 myfile"
        return
    fi
if [ "$(uname -s)" == "Linux" ]; then
        IP=$(hostname -I | awk '{print $1}')
    elif [ "$(uname -s)" == "Darwin" ]; then
        IP=$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}' |head -1)
    fi

    echo "$USER"@"$IP":"$(readlink -f "$1")"
}

# Quickly find files by name
function f () {
    if [ "$#" -ne 1 ]; then
        echo "Illegal number of parameters. Call function with file name or wildcard."
        echo "E.g. $0 *.pdf"
        return
    fi
    name=$1
    shift
    find . -name "$name" "$@"
}

# Call journalctl for process or all if no arguments
function jo () {
    if [[ "$1" != "" ]]; then
        sudo journalctl -xef -u "$1";
    else
        sudo journalctl -xef;
    fi
}


# Generate a patch email from git commits
function gpatch () {
    if [[ "$1" != "" ]]; then
        git format-patch HEAD~"$1"
    else
        git format-patch HEAD~
    fi
}

# Send patch file with git
function gsendpatch () {
  echo 'If replying to an existing message, add "--in-reply-to messageIDfromMessage@somehostname.com" param'
  patch=$1
  shift
  git send-email \
    --cc-cmd="./scripts/get_maintainer.pl --norolestats $patch" \
    "$@" "$patch"
}

# Query Docker image manifest
function qi () {
    if [ "$#" -lt 1 ]; then
        echo "Illegal number of parameters. Call function with image name."
        echo "E.g. $0 repo/image"
        return
    fi
    echo "Querying image $1"
    OUT=$(docker manifest inspect "$1" | jq -r '.manifests[] | [.platform.os, .platform.architecture] |@csv' 2> /dev/null | sed -E 's/\"(.*)\",\"(.*)\"/- \1\/\2/g' | grep -v '^/$')
    if [ $? -eq 0 ]; then
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
        if $(ldd --version 2>&1 | grep -i musl > /dev/null); then
            echo "ERROR: Distro not supported for Go."
            return 1
        fi
        declare -A ARCH=( [x86_64]=amd64 [aarch64]=arm64 [armv7l]=arm [ppc64le]=ppc64le [s390x]=s390x )
        pushd /tmp >/dev/null || return
        FILE=$(curl -sL https://golang.org/dl/?mode=json | grep -E 'go[0-9\.]+' | sed 's/.*\(go.*\.tar\.gz\).*/\1/' | sort -n | grep -i "$(uname -s)" | grep tar | grep "${ARCH[$(uname -m)]}" | tail -1)
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

# Coursier
function csi() { # fzf coursier install
  function csl() {
    unzip -l "$(cs fetch "$1":latest.stable)" | grep json | sed -E 's/.*:[0-9]{2}\s*(.+)\.json$/\1/'
  }

    cs install --contrib "$(cat <(csl io.get-coursier:apps) <(csl io.get-coursier:apps-contrib) | sort -r | fzf)"
}

function csji() { # fzf coursier java install
    cs java --jvm "$(cs java --available | fzf)" --setup
}

function csrt() { # fzf coursier resolve tree
    cs resolve -t "$1" | fzf --reverse --ansi
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

    URL=$(curl -s "${repo}" | grep "$(uname | tr LD ld)" |grep "$(uname -m)" | grep "browser_download_url" | cut -d '"' -f 4 | grep "${FILTER}" |grep -v "\(sha256\|md5\|sha1\)")
    if [ "${URL}" ]; then
        OUT=""
        if [ -n "${2+set}" ]; then
            OUT=$(echo "$2" | awk '{$1=$1};1')
        fi
        curl -s -o "${OUT}" -OL "${URL}"
    else
        return 1
    fi
}

# Checkout last tag
gcolast() {
    LASTTAG=git describe --tags "$(git rev-list --tags --max-count=1)"
    git checkout "$LASTTAG"
}