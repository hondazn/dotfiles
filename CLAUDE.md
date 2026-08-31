# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリ概要

macOS/Linux対応のdotfilesリポジトリ。外部依存を持たないbashスクリプト `install.sh` でシンボリックリンクを管理し、各設定ファイルを `~/.config/` 配下にデプロイする。

## デプロイ

```bash
./install.sh             # シンボリックリンクの作成・更新
./install.sh uninstall   # このリポジトリを指すリンクのみ削除
./test.sh                # install.shの振る舞いを検証
```

マッピング定義: `install.sh` 冒頭の `COMMON_TARGETS` / `MACOS_TARGETS` 配列 — `config/<name>` が `~/.config/<name>` にシンボリックリンクされる。macOS専用設定（karabiner, paneru）は `uname -s` で条件分岐。ターゲットは `herdr/config.toml` のようにネストしたパス（ファイル単位のリンク）も指定できる。リンク先に実体がある場合は `<name>.bak.<日時>` へ退避してから置き換える。

macOS標準のbashは3.2のため、連想配列や `mapfile` は使わない。

## アーキテクチャ

```
config/
├── nvim/        # Neovim設定 (lazy.nvim, catppuccin-mocha)
├── fish/        # Fish shell設定 (mise, sk, cargo)
├── git/         # Git設定
├── ghostty/     # Ghosttyターミナル設定
├── gh-dash/     # gh-dash設定
├── herdr/       # Herdr設定（config.tomlのみファイル単位でリンク）
├── lazygit/     # LazyGit設定
├── karabiner/   # Karabiner-Elements (macOS)
├── paneru/      # Paneru (macOS)
├── skhd/        # skhd (macOS・paneruへ移行・デプロイ対象外)
├── yabai/       # yabai (macOS・paneruへ移行・デプロイ対象外)
├── zellij/      # Zellij設定（herdrへ移行・デプロイ対象外）
├── tmux/        # tmux設定（未使用・デプロイ対象外）
└── alacritty/   # Alacritty設定（未使用・デプロイ対象外）
```

マルチプレクサは herdr を使う。`config/fish/functions/__herdr_open_tab.fish` が
`herdr tab create` と `herdr pane run` をまとめており、lazygit・gh-dash から
新しいタブでコマンドを開く用途はすべてこの関数を経由する。

### Neovim設定の構造

- `init.lua` — lazy.nvimブートストラップ、leader=Space、catppuccin-mochaテーマ
- `lua/config/` — グローバル設定（options, mappings, diagnostic, lsp）
- `lua/plugins/` — 各プラグインの設定（1ファイル1プラグイン）
- `lua/snippets/` — カスタムスニペット
- Luaフォーマッタ: StyLua (`stylua.toml`: `collapse_simple_statement = "Always"`)

### Fish shell環境

- パッケージマネージャ: Homebrew
- ランタイム管理: mise
- ファジーファインダー: sk (skim)
- エディタ: nvim

## コミットメッセージ規約

Conventional Commitsに準拠: `type(scope): message`
- 例: `feat: add claude config symlink`, `fix(lazygit): update paging config`
- scopeは変更対象のツール名（nvim, fish, git, lazygit等）
