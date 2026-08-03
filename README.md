# dotfiles

## OS
- Linux
- MacOS

## Requirements
- Git `brew install git`

## Installation
```bash
git clone git@github.com:hondazn/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## Usage
`config/<name>` を `~/.config/<name>` にシンボリックリンクする。
リンク先に実体がある場合は `<name>.bak.<日時>` へ退避してから置き換える。

```bash
./install.sh             # リンクの作成・更新
./install.sh uninstall   # このリポジトリを指すリンクのみ削除
./test.sh                # install.sh の振る舞いを検証
```
