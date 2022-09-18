# dotfiles

## OS
* Ubuntu

## Prerequirements
* curl
* git

```sh
sudo apt update && sudo apt install -y curl git build-essential  libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
```

## Install
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/honjet/dotfiles/master/setup.sh)"
```

## Neovim Configuration
### Install Plugins
Run `nvim` and execute command `:PlugInstall`

## Recommended
* Font
    * [HackGenNerd Console](https://github.com/yuru7/HackGen)
    * [Cica](https://github.com/miiton/Cica)
* Terminal
    * [alacritty](https://github.com/jwilm/alacritty)
* Terminal Multiplexer
    * [tmux](https://github.com/tmux/tmux)
* Shell
    * [fish](https://github.com/fish-shell/fish-shell)
* Others
    * [ripgrep](https://github.com/BurntSushi/ripgrep)
    * [fzf](https://github.com/junegunn/fzf)
    * [ghq](https://github.com/motemen/ghq)
    * [fd](https://github.com/sharkdp/fd)
