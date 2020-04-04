# Functions when required functionality won't work with an alias

# Generate a scp command to copy files between hosts
scppath () {
    echo $USER@`hostname -I | awk '{print $1}'`:`readlink -f $1`;
}

# Call journalctl for process or all if no arguments
jo () {
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
    OUT=$(docker manifest inspect $1 | jq -r '.manifests[] | [.platform.os, .platform.architecture] |@csv' | sed -E 's/\"(.*)\",\"(.*)\"/- \1\/\2/g' | grep -v '^/$' 2> /dev/null)
    echo $OUT

}
