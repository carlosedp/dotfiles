# Functions when required functionality won't work with an alias

# Generate a scp command to copy files between hosts
function scppath () {
    echo $USER@`hostname -I | awk '{print $1}'`:`readlink -f $1`;
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
   $(which rg) -p "$@" | less -FRX
}

# Install latest Golang. Replaces current one on /usr/local/go
function install_golang() {
    declare -A ARCH=( [x86_64]=amd64 [aarch64]=arm64 [armv7l]=arm [ppc64le]=ppc64le [s390x]=s390x ); FILE=$(curl -sL https://golang.org/dl/?mode=json | grep -E 'go[0-9\.]+' | sed 's/.*\(go.*\.tar\.gz\).*/\1/' | sort -n | grep -i $(uname -s) | grep tar | grep ${ARCH[$(uname -m)]} | tail -1); curl -sL https://dl.google.com/go/$FILE -o $FILE && sudo rm -rf /usr/local/go && sudo tar vxf $FILE -C /usr/local/ && echo "Installed $FILE" || echo "Error installing Go"
}