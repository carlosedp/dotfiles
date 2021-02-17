# Functions when required functionality won't work with an alias

function update() {
    if [ $(uname -s) == "Linux" ]; then
        $HOME/.dotfiles/setup_linux.sh
    elif [ $(uname -s) == "Darwin" ]; then
        $HOME/.dotfiles/setup_mac.sh
    fi
}

# Generate a scp command to copy files between hosts
function scppath () {
    echo $USER@$(hostname -I | awk '{print $1}'):$(readlink -f $1);
}

# Quickly find files by name
function f () {
    name=$1
    shift
    find . -name "$name" "$@"
}

# Call journalctl for process or all if no arguments
function jo () {
    if [[ "$1" != "" ]]; then
        sudo journalctl -xef -u $1;
    else
        sudo journalctl -xef;
    fi
}


# Generate a patch email from git commits
function gpatch () {
    if [[ $1 != "" ]]; then
        git format-patch HEAD~$1
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
    $@ $patch
}

# Query Docker image manifest
function qi () {
    if [ -z $1 ]; then echo "Missing image parameter."; return 1; fi
    echo "Querying image $1"
    OUT=$(docker manifest inspect $1 | jq -r '.manifests[] | [.platform.os, .platform.architecture] |@csv' 2> /dev/null | sed -E 's/\"(.*)\",\"(.*)\"/- \1\/\2/g' | grep -v '^/$')
    if [ $? -eq 0 ]; then
        echo $OUT
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
        FILE=$(curl -sL https://golang.org/dl/?mode=json | grep -E 'go[0-9\.]+' | sed 's/.*\(go.*\.tar\.gz\).*/\1/' | sort -n | grep -i $(uname -s) | grep tar | grep ${ARCH[$(uname -m)]} | tail -1)
        echo "Installing $FILE"
        curl -sL https://dl.google.com/go/$FILE -o $FILE
        sudo rm -rf /usr/local/go
        sudo tar xf $FILE -C /usr/local/ 2>/dev/null
        yes | rm -rf $FILE
    }
    install && echo "Installed $FILE" || echo "Error installing Go"
}

# Searches SSH hosts thru fzf and connects to it
function ss() {
    filter=${1:-"."}
    target=$(egrep -o "Host (\b.+\b)" ~/.ssh/config | awk '{print $2}' | grep $filter | fzf -e)
    if [ $target ]; then
        echo "Remoting into: $target"
        ssh $target
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
    cs java --jvm $(cs java --available | fzf) --setup
}

function csrt() { # fzf coursier resolve tree
    $(cs resolve -t "$1" | fzf --reverse --ansi)
}

