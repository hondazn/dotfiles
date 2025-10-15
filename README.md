# dotfiles

## OS
- Linux
- MacOS

## Prerequirements
* nix

## Installation
```bash
git clone git@github.com:hondazn/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
# macos: nix run nix-darwin -- switch --flake nix-darwin
nix run dotter -- deploy
nix run home-manager -- switch
```
