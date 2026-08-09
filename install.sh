#!/usr/bin/env bash
# config/<name> を ~/.config/<name> へシンボリックリンクする。
#
#   ./install.sh             リンクを作成・更新する
#   ./install.sh uninstall   このリポジトリを指すリンクだけを削除する
#
# macOS 標準の bash は 3.2 で止まっているため、連想配列や mapfile は使わない。
set -euo pipefail

REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONFIG_HOME="$HOME/.config"

# herdr はディレクトリにログ・ソケット・セッション状態が同居するため、
# ディレクトリごとではなく config.toml だけをファイル単位でリンクする。
COMMON_TARGETS=(git ghostty fish nvim lazygit gh-dash herdr/config.toml)
MACOS_TARGETS=(karabiner skhd yabai)
# config/alacritty と config/tmux は chezmoi から移行した際の名残。
# config/zellij はマルチプレクサを herdr へ移行した際の名残。
# いずれも使っていないため対象に含めない。

targets() {
  printf '%s\n' "${COMMON_TARGETS[@]}"
  if [ "$(uname -s)" = Darwin ]; then
    printf '%s\n' "${MACOS_TARGETS[@]}"
  fi
}

link_destination() { # <パス> -> リンクの参照先。リンクでなければ空
  if [ -L "$1" ]; then readlink "$1"; fi
}

backup_path() { # <パス> -> まだ使われていない退避先
  # local と代入を分けないと date の失敗を set -e が拾えない。
  local timestamp
  timestamp=$(date +%Y%m%d-%H%M%S)
  local base="$1.bak.$timestamp"
  local candidate=$base
  local suffix=1
  while [ -e "$candidate" ]; do
    candidate="$base.$suffix"
    suffix=$((suffix + 1))
  done
  printf '%s' "$candidate"
}

link_target() { # <name> -> ok | link | backup
  local source="$REPO_DIR/config/$1"
  local destination="$CONFIG_HOME/$1"
  local action=link

  if [ "$(link_destination "$destination")" = "$source" ]; then
    printf 'ok'
    return
  fi

  # 実体だけを退避する。リンクは中身を持たないので張り替えるだけでよい。
  if [ -e "$destination" ] && [ ! -L "$destination" ]; then
    mv "$destination" "$(backup_path "$destination")"
    action=backup
  fi

  mkdir -p "$(dirname "$destination")"
  ln -sfn "$source" "$destination"
  printf '%s' "$action"
}

unlink_target() { # <name> -> unlink | skip
  local destination="$CONFIG_HOME/$1"

  if [ "$(link_destination "$destination")" != "$REPO_DIR/config/$1" ]; then
    printf 'skip'
    return
  fi

  rm "$destination"
  printf 'unlink'
}

report() { printf '  %-6s %s\n' "$1" "$2"; }

install_all() {
  local name action
  local linked=0 restored=0 unchanged=0

  mkdir -p "$CONFIG_HOME"
  while read -r name; do
    action=$(link_target "$name")
    report "$action" "$CONFIG_HOME/$name"
    case "$action" in
      link) linked=$((linked + 1)) ;;
      backup) linked=$((linked + 1)); restored=$((restored + 1)) ;;
      ok) unchanged=$((unchanged + 1)) ;;
    esac
  done < <(targets)

  printf '\n%d linked, %d backed up, %d unchanged\n' "$linked" "$restored" "$unchanged"
}

uninstall_all() {
  local name action
  local removed=0 kept=0

  while read -r name; do
    action=$(unlink_target "$name")
    report "$action" "$CONFIG_HOME/$name"
    case "$action" in
      unlink) removed=$((removed + 1)) ;;
      skip) kept=$((kept + 1)) ;;
    esac
  done < <(targets)

  printf '\n%d unlinked, %d skipped\n' "$removed" "$kept"
}

case "${1:-install}" in
  install) install_all ;;
  uninstall) uninstall_all ;;
  *)
    printf 'usage: %s [install|uninstall]\n' "$0" >&2
    exit 2
    ;;
esac
