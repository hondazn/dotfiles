# Neovim設定

## Requirements

- Neovim 0.12+ — `vim.lsp.config` / `vim.lsp.enable` と `virtual_lines` 診断に依存
- git / Cコンパイラ — treesitterパーサのビルドに必要
- Nerd Fonts
- ripgrep — `Snacks.picker` のgrep
- lazygit — `<leader>gg`
- ghq — `<leader>fp` のプロジェクト一覧が `ghq list --full-path` を実行
- fish — `Snacks.terminal` のシェル

### Language Server

`lua/config/lsp.lua` で有効化しているもの。TypeScriptはプロジェクトの `node_modules` 側を使う。

- lua-language-server
- rust-analyzer
- haskell-language-server
- oxlint

### Formatter

`lua/plugins/conform.lua` の割り当て。

- stylua — lua
- oxfmt — ts / js / json / html / css / yaml / toml / markdown
- rustfmt — rust

### Options

- gh — octo.nvim (`<leader>gh*`)
- imagemagick — `Snacks.image` の画像プレビュー

## Installation

dotfilesリポジトリのルートで実行する。

```sh
./install.sh
```

nvimで起動したら、 `:Copilot auth` で Copilot を使えるようにしておく。
