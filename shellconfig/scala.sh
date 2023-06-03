#!/usr/bin/env bash

# These are Scala development environment functions/aliases

# Add Temporal to path and load completions
export PATH=$HOME/.temporalio/bin:$PATH
source "$HOME/.dotfiles/completion/_temporal"

alias scli='scala-cli'
alias amm='scala-cli repl --ammonite -O --thin'
alias amm2='scala-cli repl --scala 2 --ammonite -O --thin'

# Use Coursier to list, install and use Java
alias javainstalled='cs java --installed | column -t'
alias javalist='cs java --available | fzf --preview-window=,hidden --reverse'

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

#If keepMajor is true, functions will only use major versions (no daily builds)
export keepMajorMillVersion=true

# Update Scala Mill `.mill-version` file with latest build
millupd() {
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

function prompt_mill_version() {
    # This function is meant to be used on Zsh P10k prompt. To use, add `mill_version` in the `p10k.zsh` file:
    #       typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    #       status # already exists
    #       ...
    #       mill_version
    #       ...
    #       )
    if [ -f ".mill-version" ] ; then
        local millver
        millver=$(cat .mill-version || echo 'bug')
    else
        return
    fi

    local cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/p10k-${(%):-%n}/millversion
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

    if [[ -n "$latest_mill_version" && "$millver" != "$latest_mill_version" ]]; then
        p10k segment -s "NOT_UP_TO_DATE" -f red -i '' -t "⇣$millver  [$latest_mill_version]"
    else
        p10k segment -s "UP_TO_DATE" -f blue -i '' -t "$millver"
    fi
}
