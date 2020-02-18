# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=50000000;
export HISTFILESIZE=$HISTSIZE;
export HISTCONTROL=ignoredups;
# Make some commands not show up in history
export HISTIGNORE=" *:ls:cd:cd -:pwd:exit:date:* --help:* -h:pony:pony add *:pony update *:pony save *:pony ls:pony ls *:history*";
export HISTTIMEFORMAT="%d/%m/%y %T "

# Prefer US English and use UTF-8
export LANG="en_US.UTF-8";
export LC_ALL="en_US.UTF-8";

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X";

# Do not clear screen after exiting LESS
unset LESS

# Add alt-up/down keybinding to fzf preview window
export FORGIT_FZF_DEFAULT_OPTS="
$FORGIT_FZF_DEFAULT_OPTS
--bind='alt-up:preview-up'
--bind='alt-down:preview-down'
--no-mouse
"

