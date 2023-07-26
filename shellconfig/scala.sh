#!/usr/bin/env bash

# These are Scala development environment functions/aliases
# Most functions require Coursier and FZF to be installed

# Set default JVM to use (graalvm-java17, zulu, etc.)
export JVM=graalvm-java17

# Check if fzf is installed
if [ ! -x "$(command -v fzf)" ] >/dev/null 2>&1; then
    echo "FZF not installed. Install from https://github.com/junegunn/fzf"
fi

# Scala Coursier Path for Mac and Linux
export PATH="$HOME/Library/Application Support/Coursier/bin:$PATH"
export PATH="$HOME/.local/share/coursier/bin:$PATH"

# Add Java to path (if coursier is installed)
JAVA_HOME=/usr/local/java
if [ -x "$(command -v cs)" ] ; then
    if [[ "$(cs java-home --jvm ${JVM} > /dev/null 2>&1)" -eq 0 ]]; then
        JAVA_HOME=$(cs java-home --jvm ${JVM})
    fi
    export JAVA_HOME
    export PATH=$JAVA_HOME/bin:$PATH
fi

alias scli='scala-cli'
alias amm='scala-cli repl --ammonite -O --thin'
alias amm2='scala-cli repl --scala 2 --ammonite -O --thin'

# Use Coursier to list, install and use Java
alias javainstalled='cs java --installed | column -t'
alias javalist='cs java --available | fzf --preview-window=,hidden --reverse'

# Set default JVM to use (graalvm-java17, zulu, etc.) on scala.sh file
javasetdefault() {
    USE=$(cs java --available |cut -d":" -f1| sort -u | fzf --preview-window=,hidden --reverse --prompt="Select JDK")
    sed -i "s/^export JVM=.*/export JVM=${USE}/" "$HOME/.dotfiles/shellconfig/scala.sh"
    echo "Loading the new config and installing $USE if needed..."
    source "$HOME/.dotfiles/shellconfig/scala.sh"
    echo "Default JVM set to $JVM."
}

# Install Java using Coursier
javainstall() {
    USE=$(cs java --available | fzf --preview-window=,hidden --reverse --prompt="Select JDK to install")
    cs java --jvm "$USE"
}

# Switch Java version using Coursier
javause() {
    USE=$(cs java --installed  | cut -d" " -f1 | fzf --preview-window=,hidden --reverse --prompt="Select JDK")
    eval "$(cs java --jvm "$USE" --env)"
    export PATH=$JAVA_HOME/bin:$PATH
}

javaupd() {
    # JVM var comes from `shellconfig/exports.sh` defining which JVM to use (adptium, graalvm-java17, zulu, etc.)
    echo "Checking installed Java versions..."
    INSTALLEDJAVA=$(cs java --installed | grep "$JVM")
    CURRENTJAVA=$(echo "$INSTALLEDJAVA" | cut -d" " -f1)
    CURRENTPATH=$(echo "$INSTALLEDJAVA" | cut -d" " -f4)
    CURRENTVERSION=$(echo "$CURRENTJAVA" | cut -d":" -f2)
    LATESTJAVA=$(cs java --available | grep "$JVM" | tail -1 | cut -d":" -f2)
    if [ "$CURRENTVERSION" = "$LATESTJAVA" ]; then
        echo "Java $JVM is already up-to-date at version $CURRENTVERSION."
        return
    fi
    echo "Current Java is $CURRENTJAVA at $CURRENTPATH"
    echo "Removing current Java $JVM..."
    rm -rf "$(realpath "$CURRENTPATH/../../..")"
    echo "Installing latest Java $JVM version $LATESTJAVA..."
    cs java --jvm "$JVM"
    echo "Java $JVM is now at version $LATESTJAVA, reload your shell to load the right path."
}

javaremove() {
    USE=$(cs java --installed | fzf --preview-window=,hidden --reverse --prompt="Select JDK to remove" --with-nth=1)
    echo "$USE"
    rm -rf "$(realpath "$(echo "$USE" | cut -d" " -f4)/../../../..")"
}

# Coursier Install package
function csi() { # fzf coursier install
  function csl() {
    unzip -l "$(cs fetch "$1":latest.stable)" | grep json | sed -E 's/.*:[0-9]{2}\s*(.+)\.json$/\1/'
  }
    cs install --contrib "$(cat <(csl io.get-coursier:apps) <(csl io.get-coursier:apps-contrib) | fzf --preview-window=,hidden --reverse --prompt="Select app to install")"
}

# Coursier Resolve tree for package
function csrt() { # fzf coursier resolve tree
    cs resolve -t "$1" | fzf --reverse --ansi
}

alias cleansproj='rm -rf .bsp .metals .bloop .scala-build .ammonite out target project/target project/project'
alias bloopgen='mill --import ivy:com.lihaoyi::mill-contrib-bloop:  mill.contrib.bloop.Bloop/install'

# Update Scala Mill `.mill-version` file with latest build
millupd() {
    stickToMajorVersion="${1:-true}"
    if [ $stickToMajorVersion = "-m" ] ; then
        keepMajorMillVersion=false
    else
        keepMajorMillVersion=true
    fi
    if [ -f ".mill-version" ] ; then
        rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}"/p10k-${(%):-%n}/millversion/latest_mill_version
        latest_mill_version=$(curl -sL https://repo1.maven.org/maven2/com/lihaoyi/mill-scalalib_2.13/maven-metadata.xml | grep "<version>" |grep -v "\-M" |tail -1 |sed -e 's/<[^>]*>//g' |tr -d " ")
        echo "Latest mill version is $latest_mill_version..."
        if [ "$keepMajorMillVersion" = true ]; then
            latest_mill_version=$(echo "$latest_mill_version" | cut -d- -f1)
            echo "Will stick to major version $latest_mill_version"
        fi
        millver=$(cat .mill-version || echo 'bug')
        if [[ -n "$latest_mill_version" && "$millver" != "$latest_mill_version" ]]; then
            echo "Version differs, currently in $millver... updating .mill-version to $latest_mill_version."
            echo "$latest_mill_version" > .mill-version
        else
            echo "Mill is already up-to-date."
        fi
    else
      return
    fi
}

# This function is used by Zsh P10k prompt. To use, add `mill_version` in the `p10k.zsh` file:
#       typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
#       status # already exists
#       ...
#       mill_version
#       ...
#       )
function prompt_mill_version() {
    if [ -f ".mill-version" ] ; then
        local millver
        millver=$(cat .mill-version || echo 'bug')
    else
        return
    fi
    #If keepMajor is true, functions will only use major versions (no daily builds)
    keepMajorMillVersion=true

    local cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/p10k-${(%):-%n}
    mkdir -p "$cache_dir" # just ensuring that it exists
    local cache_file="$cache_dir/latest_mill_version"

    local timeout_in_hours=24
    local timeout_in_seconds=$(($timeout_in_hours*60*60))

    if [[ ! (-f "$cache_file" && $(($(date +%s) - $(stat -c '%Y' "$cache_file") < $timeout_in_seconds)) -gt 0) ]]; then
        local latest_mill_version_maven
        latest_mill_version_maven=$(curl -sL https://repo1.maven.org/maven2/com/lihaoyi/mill-scalalib_2.13/maven-metadata.xml | grep "<version>" |grep -v "\-M" |tail -1 |sed -e 's/<[^>]*>//g' |tr -d " ")
        if [ "$keepMajorMillVersion" = true ]; then
            latest_mill_version_maven=$(echo "$latest_mill_version_maven" | cut -d- -f1)
        fi

        if [[ -n "$latest_mill_version_maven" ]]; then
            echo "$latest_mill_version_maven" > "$cache_file"
        else
            touch "$cache_file"
        fi
    fi

    local latest_mill_version
    latest_mill_version=$(cat "$cache_file")

    if [[ -n "$latest_mill_version" && "$millver" != $(echo "$latest_mill_version" | cut -d- -f1)  && "$millver" != "$latest_mill_version" ]];
    then
        p10k segment -s "UP_TO_DATE" -f yellow -i '' -t "⇡ Mill $millver"
    elif [[ -n "$latest_mill_version" && "$millver" != "$latest_mill_version" ]]; then
        p10k segment -s "NOT_UP_TO_DATE" -f red -i '' -t "⇣ Mill $millver  [$latest_mill_version]"
    else
        p10k segment -s "UP_TO_DATE" -f blue -i '' -t "Mill $millver"
    fi
}

# This function is used by Zsh P10k prompt. To use, add `bleep_version` in the `p10k.zsh` file:
#       typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
#       status # already exists
#       ...
#       bleep_version
#       ...
#       )
function prompt_bleep_version() {
    if [ -f "bleep.yaml" ] ; then
        local bleepver
        bleepver=$(cat bleep.yaml |grep "\$version" | cut -d: -f2 |tr -d " ")
    else
        return
    fi
    local cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/p10k-${(%):-%n}
    mkdir -p "$cache_dir" # just ensuring that it exists
    local cache_file="$cache_dir/latest_bleep_version"

    local timeout_in_hours=24
    local timeout_in_seconds=$(($timeout_in_hours*60*60))

    if [[ ! (-f "$cache_file" && $(($(date +%s) - $(stat -c '%Y' "$cache_file") < $timeout_in_seconds)) -gt 0) ]]; then
        local latest_bleep_version
        latest_bleep_version=$(curl -sSf https://api.github.com/repos/oyvindberg/bleep/releases |grep tag_name | head -1 | cut -d: -f2 |tr -d "\",v\ ")

        if [[ -n "$latest_bleep_version" ]]; then
            echo "$latest_bleep_version" > "$cache_file"
        else
            touch "$cache_file"
        fi
    fi

    local latest_bleep_version
    latest_bleep_version=$(cat "$cache_file")

    if [[ -n "$latest_bleep_version" && "$bleepver" != $(echo "$latest_bleep_version" | cut -d- -f1)  && "$bleepver" != "$latest_bleep_version" ]];
    then
        p10k segment -s "UP_TO_DATE" -f yellow -i '' -t "⇡ Bleep $bleepver"
    elif [[ -n "$latest_bleep_version" && "$bleepver" != "$latest_bleep_version" ]]; then
        p10k segment -s "NOT_UP_TO_DATE" -f red -i '' -t "⇣ Bleep $bleepver  [$latest_bleep_version]"
    else
        p10k segment -s "UP_TO_DATE" -f blue -i '' -t "Bleep $bleepver"
    fi
}

# Add Temporal to path and load completions
export PATH=$HOME/.temporalio/bin:$PATH
source "$HOME/.dotfiles/completion/_temporal"
