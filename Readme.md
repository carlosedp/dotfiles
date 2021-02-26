# Console Dotfiles

This is an attempt to document my dotfiles and each directory/file purpose. The configuration should be similar between `bash` and `zsh` shells. I use `zsh` by default.

## Installing

There is a kickstart script that automates install on both. You need at least `sudo`, `bash`, `ca-certificates` and `curl` installed. For your distro, run as root:

* Debian/Ubuntu: `apt update && apt install -y --no-install-recommends sudo bash curl ca-certificates`
* Alpine: `apk add sudo bash curl ca-certificates`
* Fedora/CentOS: `dnf install -y sudo bash curl ca-certificates`
* Void Linux: `xbps-install -Su -y sudo bash curl ca-certificates`

Then, run:

```sh
curl -Ls https://github.com/carlosedp/dotfiles/raw/master/kickstart.sh | bash
```

The dotfiles serves both Linux and Mac hosts. I have different methods of setting each up manually.

### Mac

On Mac, the process to setup is:

```sh
# Checkout the files
git clone https://github.com/carlosedp/dotfiles $HOME/.dotfiles
pushd $HOME/.dotfiles

# Run setup_mac.sh
./setup_mac.sh
popd
```

Now close the current terminal and reopen.

### Linux

On Linux, the process to setup is:

```sh
# Checkout the files
git clone https://github.com/carlosedp/dotfiles $HOME/.dotfiles
pushd $HOME/.dotfiles

# Run setup_linux.sh
./setup_linux.sh
popd
```

Now close the current terminal and reopen.

## File/Dir Structure

The dotfiles is structured as:

### Directories

* `./bin` - These are some utility scripts or platform specific binaries. These are added to the `$PATH`
* `./completion` - Holds custom command completion scripts for bash and zsh
* `./fonts` - Console monospaced fonts. Some have been patched with [nerdfonts](https://github.com/ryanoasis/nerd-fonts) to have special characters. Needs to be installed manually depending on the platform.
* `./mac` - This dir holds Mac application config files that are linked to `Library/Preferences` in the user home dir. They are automatically linked by the `setup_links.sh` if the host is a Mac.
* `./rc` - This dir holds application config files and directories that are linked as `.filerc` in the user home dir. They are automatically linked by the `setup_links.sh` script and their link will have the `.` prepended.
* `./rc/iterm2` - iTerm2 utilities installed by the "Install Shell Integration" menu option
* `./shellconfig` - This directory has the shell config variables for both `bash` and `zsh`
* `./themes` - Theme files for Tmux, iTerm2 and others

### File roles

**Files in `./`:**

* `.ignore` - Ignores some files that contain personal data and should not be in GitHub
* `Brewfile` - Homebrew packages installed on Mac. Install by using `brew bundle install`. Called by `setup_mac.sh`.
* `Brewfile-casks-store` - Homebrew cask packages installed on Mac. Install by using `brew bundle install --file Brewfile-casks-store`. Called by `setup_mac.sh`.
* `setup_apps.sh` - Installs additional utility applications like Hub, fzf kubectl, etc.
* `kickstart.sh` - Initial script that can be called thru Curl to start the setup on any kind of host  (Linux or Mac).
* `osx_prefs.sh` - Configures MacOS `default` settings. Called by `setup_mac.sh`.
* `setup_links.sh` - Configures symbolic links to directories and rc files. Called by `setup_mac.sh`, `setup_tmux.sh` and `setup_zsh.sh`.
* `setup_mac.sh` - Setup Mac with command line tools, Homebrew package manager. Installs homebrew applications, fonts, go applications, links, zsh, tmux thru aux scripts. All Mac related setup goes here.
* `setup_linux.sh` - Setup Linux with basic packages. Installs go applications, links, zsh, tmux thru aux scripts. All Linux related setup goes here.
* `setup_apps.sh` - Setup application specific configs and themes.
* `setup_tmux.sh` - Installs and configure Tmux on any platform (Mac / Linux)
* `setup_zsh.sh` - Installs and configures Zsh, its plugins and theme. Sets it as default for current user. Also updates all packages and dependencies whenever run.
* `update_completions.sh` - Updates Zsh and Bash completion scripts stored on `~/.dotfiles/completion`.

**Files in the `./shellconfig` directory:**

* `./shellconfig/shellrc.sh` - This is called by `.zshrc` and `.bashrc`. Loads shell configuration that is common for zsh and bash. Sources the aliases, exports, functions, iTerm2 integration and any utility completion or plugin. Calls Neofetch at the end.
* `./shellconfig/aliases.sh` - Aliases common to Mac and Linux
* `./shellconfig/aliases_mac.sh` - Aliases specific to MacOS and depending on Mac applications
* `./shellconfig/exports.sh` - Exports for both Mac and Linux. Generic shell config, utilities and PATH.
* `./shellconfig/funcs.sh` - Define some functions where behaviour is too complex for an alias
* `./shellconfig/iterm_shell_integration.*` - These are the scripts loaded for iTerm2 integration
* `./shellconfig/kubernetes.sh` - Kubernetes functions and aliases. Loaded only when `kubectl` is present.

