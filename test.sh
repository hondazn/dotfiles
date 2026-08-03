#!/usr/bin/env bash
# install.sh の振る舞いを検証する。HOME を一時ディレクトリに差し替えるため、
# 実際の ~/.config には一切触れない。
set -uo pipefail

REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
INSTALL="$REPO_DIR/install.sh"

passed=0
failed=0

check() { # <説明> <実際> <期待>
  if [ "$2" = "$3" ]; then
    passed=$((passed + 1))
    printf '  PASS  %s\n' "$1"
  else
    failed=$((failed + 1))
    printf '  FAIL  %s\n        expected: %s\n        actual:   %s\n' "$1" "$3" "$2"
  fi
}

fake_home() { mktemp -d "${TMPDIR:-/tmp}/dotfiles-test.XXXXXX"; }

path_state() { # <パス> -> present | absent
  if [ -e "$1" ] || [ -L "$1" ]; then printf present; else printf absent; fi
}

backup_count() { # <ディレクトリ> -> バックアップ数
  # ディレクトリ自体が無い場合に 0 を返すと「何も起きていない」ことを
  # 見逃すため、数値にならない値を返して必ず失敗させる。
  if [ ! -d "$1" ]; then
    printf 'no-such-directory'
    return
  fi
  find "$1" -maxdepth 1 -name '*.bak.*' | wc -l | tr -d ' '
}

test_creates_link_when_target_missing() {
  local home
  home=$(fake_home)

  HOME="$home" "$INSTALL" >/dev/null

  check 'creates link when target missing' \
    "$(readlink "$home/.config/git")" "$REPO_DIR/config/git"
  rm -rf "$home"
}

test_stays_idempotent_on_second_run() {
  local home
  home=$(fake_home)
  HOME="$home" "$INSTALL" >/dev/null

  HOME="$home" "$INSTALL" >/dev/null

  check 'keeps link intact on second run' \
    "$(readlink "$home/.config/nvim")" "$REPO_DIR/config/nvim"
  check 'creates no backup on second run' \
    "$(backup_count "$home/.config")" 0
  rm -rf "$home"
}

test_backs_up_existing_directory() {
  local home
  home=$(fake_home)
  mkdir -p "$home/.config/nvim"
  printf 'original\n' >"$home/.config/nvim/init.lua"

  HOME="$home" "$INSTALL" >/dev/null

  check 'links over existing real directory' \
    "$(readlink "$home/.config/nvim")" "$REPO_DIR/config/nvim"
  check 'preserves original content in backup' \
    "$(cat "$home"/.config/nvim.bak.*/init.lua)" original
  rm -rf "$home"
}

test_relinks_dead_symlink() {
  local home
  home=$(fake_home)
  mkdir -p "$home/.config"
  ln -s "$home/nowhere" "$home/.config/fish"

  HOME="$home" "$INSTALL" >/dev/null

  check 'relinks dead symlink' \
    "$(readlink "$home/.config/fish")" "$REPO_DIR/config/fish"
  check 'creates no backup for dead symlink' \
    "$(backup_count "$home/.config")" 0
  rm -rf "$home"
}

test_uninstall_removes_only_repo_links() {
  local home
  home=$(fake_home)
  HOME="$home" "$INSTALL" >/dev/null
  check 'creates link before uninstall' \
    "$(path_state "$home/.config/git")" present
  mkdir -p "$home/elsewhere"
  ln -sfn "$home/elsewhere" "$home/.config/lazygit"

  HOME="$home" "$INSTALL" uninstall >/dev/null

  check 'removes link into this repository' \
    "$(path_state "$home/.config/git")" absent
  check 'keeps link pointing outside this repository' \
    "$(readlink "$home/.config/lazygit")" "$home/elsewhere"
  rm -rf "$home"
}

for testcase in \
  test_creates_link_when_target_missing \
  test_stays_idempotent_on_second_run \
  test_backs_up_existing_directory \
  test_relinks_dead_symlink \
  test_uninstall_removes_only_repo_links; do
  "$testcase"
done

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
