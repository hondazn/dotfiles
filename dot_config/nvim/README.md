# Neovim設定

## Requirements
- Neovim
- lazygit
- Nerdfonts
- ripgrep
- sqlite3
- Lua Language Server

### Options
- stylua

## Installation
```sh
mv ~/.config/nvim ~/.config/nvim.bak
git clone git@github.com:hondazn/config.nvim.git
cd config.nvim
ln -s $(pwd) ~/.config/nvim
```

nvimで起動したら、 `:Copilot auth` で Copilot を使えるようにしておく。
