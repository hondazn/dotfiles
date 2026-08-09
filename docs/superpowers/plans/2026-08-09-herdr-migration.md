# zellij → herdr 移行 実装計画

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** マルチプレクサのメインを zellij から herdr に切り替え、zellij に依存した設定を herdr 版へ置き換えるか、herdr 標準機能に吸収されるものは削除する。

**Architecture:** herdr の CLI にはコマンド終了時にペインを閉じる属性がないため、`tab create` の JSON から `pane_id` を取り `pane run "<cmd>; exit"` する手順を fish 関数 1 本（`__herdr_open_tab`）に閉じ込め、lazygit / gh-dash / fish 関数はすべてそれを経由する。zellij 時代に fish で手作りしていたタブ名更新とレイアウト起動は herdr が標準で持つため削除する。

**Tech Stack:** bash 3.2 互換シェルスクリプト（install.sh / test.sh）、fish shell 関数、TOML（herdr）、YAML（lazygit / gh-dash）

## Global Constraints

- 対象は herdr v0.8.0。設定の正本は `herdr --default-config` の出力
- macOS 標準の bash は 3.2 のため、`install.sh` / `test.sh` で連想配列と `mapfile` を使わない
- コミットメッセージは Conventional Commits（`type(scope): message`、scope は変更対象のツール名）
- `config/zellij/` 一式と `config/lazygit/agent-coding.yml` は凍結。中身を変更しない
- `herdr config check` は既定値との衝突を検出しない。キー変更時は `herdr --default-config` と目視で照合する
- 新規・変更した fish 関数は `fish -n <path>` で構文チェックする

---

### Task 1: zellij をデプロイ対象から外す

**Files:**
- Modify: `install.sh:13-18`
- Test: `test.sh`

**Interfaces:**
- Produces: `COMMON_TARGETS` から `zellij` が消える。`~/.config/zellij` は作られない

- [ ] **Step 1: 作業ブランチを切る**

現在 `master` に未コミットの差分（`CLAUDE.md` / `config/lazygit/config.yml` / `install.sh` / `test.sh` / `config/herdr/`）があるので、それごと作業ブランチへ移す。

```bash
git switch -c feat/migrate-to-herdr
git status --short
```

Expected: 差分がそのまま作業ブランチ上に見える

- [ ] **Step 2: 失敗するテストを書く**

`test.sh` の `test_uninstall_removes_only_repo_links` の直前に追加する。

```bash
test_skips_retired_targets() {
  local home
  home=$(fake_home)

  HOME="$home" "$INSTALL" >/dev/null

  check 'does not link retired zellij config' \
    "$(path_state "$home/.config/zellij")" absent
  rm -rf "$home"
}
```

同ファイル末尾のテストランナーにも登録する。

```bash
for testcase in \
  test_creates_link_when_target_missing \
  test_stays_idempotent_on_second_run \
  test_backs_up_existing_directory \
  test_relinks_dead_symlink \
  test_links_nested_file_target \
  test_uninstall_keeps_parent_of_nested_target \
  test_skips_retired_targets \
  test_uninstall_removes_only_repo_links; do
  "$testcase"
done
```

- [ ] **Step 3: テストが失敗することを確認する**

Run: `./test.sh`
Expected: `FAIL  does not link retired zellij config` / `expected: absent` / `actual: present`

- [ ] **Step 4: install.sh を修正する**

`install.sh:13-18` を次に置き換える。

```bash
# herdr はディレクトリにログ・ソケット・セッション状態が同居するため、
# ディレクトリごとではなく config.toml だけをファイル単位でリンクする。
COMMON_TARGETS=(git ghostty fish nvim lazygit gh-dash herdr/config.toml)
MACOS_TARGETS=(karabiner skhd yabai)
# config/alacritty と config/tmux は chezmoi から移行した際の名残。
# config/zellij はマルチプレクサを herdr へ移行した際の名残。
# いずれも使っていないため対象に含めない。
```

- [ ] **Step 5: テストが通ることを確認する**

Run: `./test.sh`
Expected: `14 passed, 0 failed`（変更前は 13 passed）

- [ ] **Step 6: 既存の ~/.config/zellij リンクを外す**

`uninstall` はこのリポジトリを指すリンクだけを削除するので、先に旧定義のまま実行しても zellij は消えない。手動で外す。

```bash
readlink ~/.config/zellij
```

Expected: `/home/zyun/git/github.com/hondazn/dotfiles/config/zellij`

```bash
rm ~/.config/zellij
```

- [ ] **Step 7: コミット**

```bash
git add install.sh test.sh
git commit -m "chore: drop zellij from deploy targets"
```

---

### Task 2: herdr の新タブヘルパーを追加する

**Files:**
- Create: `config/fish/functions/__herdr_open_tab.fish`

**Interfaces:**
- Produces: `__herdr_open_tab [--cwd PATH] [--label TEXT] [--focus] <command-string>`
  - `$HERDR_ENV` が未設定なら stderr にメッセージを出して 1 を返す
  - コマンド引数が空なら stderr にメッセージを出して 1 を返す
  - `$HERDR_WORKSPACE_ID` の workspace に新タブを作り、コマンド終了時にタブごと閉じる
  - `--focus` を付けない限り `--no-focus`（フォーカスは呼び出し元に残る）
  - Task 3 がこの関数を使う。Task 4（lazygit）は同一ペインで nvim を開くため使わない

- [ ] **Step 1: ヘルパーを書く**

```fish
function __herdr_open_tab -d 'Run a command in a new herdr tab that closes when the command exits'
    argparse 'cwd=' 'label=' 'focus' -- $argv
    or return 1

    if test -z "$HERDR_ENV"
        echo "__herdr_open_tab: must be run inside herdr" >&2
        return 1
    end

    if test (count $argv) -eq 0
        echo "__herdr_open_tab: no command given" >&2
        return 1
    end

    set -l opts --workspace $HERDR_WORKSPACE_ID
    set -q _flag_cwd; and set -a opts --cwd $_flag_cwd
    set -q _flag_label; and set -a opts --label $_flag_label
    if set -q _flag_focus
        set -a opts --focus
    else
        set -a opts --no-focus
    end

    set -l pane (herdr tab create $opts | jq -r '.result.root_pane.pane_id')
    if test -z "$pane" -o "$pane" = null
        echo "__herdr_open_tab: failed to create tab" >&2
        return 1
    end

    # herdr にはコマンド終了時にペインを閉じる属性がないため exit を足す。
    herdr pane run $pane (string join ' ' -- $argv)"; exit"
end
```

- [ ] **Step 2: 構文チェック**

Run: `fish -n config/fish/functions/__herdr_open_tab.fish`
Expected: 出力なし（終了ステータス 0）

`config/fish` はディレクトリ単位でリンク済みのため、新規ファイルは `install.sh` を再実行しなくても有効になる。

- [ ] **Step 3: herdr 外での失敗を確認する**

Run: `env -u HERDR_ENV fish -c 'source config/fish/functions/__herdr_open_tab.fish; __herdr_open_tab "echo hi"; echo "status=$status"'`
Expected: `__herdr_open_tab: must be run inside herdr` と `status=1`

- [ ] **Step 4: 引数なしでの失敗を確認する**

Run: `fish -c 'source config/fish/functions/__herdr_open_tab.fish; __herdr_open_tab; echo "status=$status"'`
Expected: `__herdr_open_tab: no command given` と `status=1`

- [ ] **Step 5: 実機で新タブが開いて閉じることを確認する**

herdr のペイン内から実行する。

```bash
fish -ic '__herdr_open_tab --cwd /tmp --label probe "echo PROBE_OK"'
herdr tab list --workspace "$HERDR_WORKSPACE_ID"
```

Expected: `tab list` に `probe` が現れず（コマンドが即終了して閉じるため）、エラーも出ない。タブの生成自体を目視したい場合は `"sleep 5"` に置き換えて実行し、5 秒後に消えることを確認する

- [ ] **Step 6: コミット**

```bash
git add config/fish/functions/__herdr_open_tab.fish
git commit -m "feat(fish): add herdr new-tab helper"
```

---

### Task 3: gh-dash を herdr へ移す

**Files:**
- Modify: `config/fish/functions/gh-dash-pr-nvim.fish`
- Modify: `config/fish/functions/gh-dash-pr-shell.fish`
- Modify: `config/gh-dash/config.yml:79-108`
- Delete: `config/fish/functions/gh-dash-pr-copilot.fish`

**Interfaces:**
- Consumes: `__herdr_open_tab`（Task 2）
- Produces: gh-dash のキーは `D`（diff）/ `N`（nvim）/ `I`（shell）の 3 つになる

- [ ] **Step 1: gh-dash-pr-nvim.fish を書き換える**

ファイル全体を次に置き換える。

```fish
function gh-dash-pr-nvim -d 'Open a PR worktree in nvim inside a new herdr tab'
    argparse 'repo=' 'pr=' 'repo-path=' 'head-ref=' -- $argv
    or return 1

    set -l wt (__gh-dash-pr-worktree \
        --repo $_flag_repo \
        --pr $_flag_pr \
        --repo-path $_flag_repo_path \
        --head-ref $_flag_head_ref)
    or return 1

    __herdr_open_tab --cwd "$wt" --label "nvim #$_flag_pr" --focus nvim
end
```

- [ ] **Step 2: gh-dash-pr-shell.fish を書き換える**

ファイル全体を次に置き換える。

```fish
function gh-dash-pr-shell -d 'Open a fish shell in the PR worktree inside a new herdr tab'
    argparse 'repo=' 'pr=' 'repo-path=' 'head-ref=' -- $argv
    or return 1

    set -l wt (__gh-dash-pr-worktree \
        --repo $_flag_repo \
        --pr $_flag_pr \
        --repo-path $_flag_repo_path \
        --head-ref $_flag_head_ref)
    or return 1

    __herdr_open_tab --cwd "$wt" --label "shell #$_flag_pr" --focus fish
end
```

- [ ] **Step 3: copilot 関数を削除する**

```bash
git rm config/fish/functions/gh-dash-pr-copilot.fish
```

- [ ] **Step 4: gh-dash の keybindings を書き換える**

`config/gh-dash/config.yml` の `keybindings:` ブロック全体を次に置き換える。`O`（octo）と `C`（copilot）を削除し、`D` を herdr 経由にする。

```yaml
keybindings:
  prs:
    - key: D
      name: diff
      command: >
        fish -ic "__herdr_open_tab --label 'diff #{{.PrNumber}}' --focus
        'gh pr diff {{.PrNumber}} -R {{.RepoName}} | delta --dark --paging=always --tabs=4 --true-color=auto --line-numbers'"
    - key: N
      name: nvim
      command: >
        fish -ic "gh-dash-pr-nvim
        --repo '{{.RepoName}}'
        --pr '{{.PrNumber}}'
        --repo-path '{{.RepoPath}}'
        --head-ref '{{.HeadRefName}}'"
    - key: I
      name: shell
      command: >
        fish -ic "gh-dash-pr-shell
        --repo '{{.RepoName}}'
        --pr '{{.PrNumber}}'
        --repo-path '{{.RepoPath}}'
        --head-ref '{{.HeadRefName}}'"
```

- [ ] **Step 5: 構文チェック**

```bash
fish -n config/fish/functions/gh-dash-pr-nvim.fish
fish -n config/fish/functions/gh-dash-pr-shell.fish
python3 -c "import yaml,sys; yaml.safe_load(open('config/gh-dash/config.yml')); print('yaml ok')"
```

Expected: fish は出力なし、最後に `yaml ok`

- [ ] **Step 6: zellij 参照が消えたことを確認する**

Run: `grep -rn zellij config/gh-dash config/fish`
Expected: Task 5 で削除する `zellij_tab.fish` / `__zellij_tab_rename.fish` / `agent-coding.fish` の 3 ファイルだけがヒットする

- [ ] **Step 7: 実機で gh-dash の N キーを確認する**

```bash
gh-dash
```

PR を選んで `N` を押す。Expected: PR worktree の cwd で nvim が新タブに開き、`:q` で抜けるとタブが閉じる

- [ ] **Step 8: コミット**

```bash
git add config/fish/functions/gh-dash-pr-nvim.fish config/fish/functions/gh-dash-pr-shell.fish config/gh-dash/config.yml
git commit -m "feat(gh-dash): open PR worktrees in herdr tabs and drop review keys"
```

---

### Task 4: lazygit のエディタ呼び出しを herdr 前提にする

**Files:**
- Modify: `config/lazygit/config.yml:12-16`

**Interfaces:**
- Produces: lazygit がエディタ呼び出し時にサスペンドし、同一ペインで nvim が開く

- [ ] **Step 1: os セクションを書き換える**

`config/lazygit/config.yml` の `os:` ブロックを次に置き換える。

```yaml
os:
  edit: 'nvim {{filename}}'
  editAtLine: 'nvim +{{line}} {{filename}}'
  editAtLineAndWait: 'nvim +{{line}} {{filename}}'
  editInTerminal: true
```

`editInTerminal` はコマンド個別ではなく「lazygit が自身をサスペンドするか」を決める全体設定で、`editAtLineAndWait` だけ同期にする分岐は書けない。herdr には zellij の `--blocking` に相当する機能が無いため、3 つとも同一ペインに統一する。

- [ ] **Step 2: YAML 構文チェック**

Run: `python3 -c "import yaml; yaml.safe_load(open('config/lazygit/config.yml')); print('yaml ok')"`
Expected: `yaml ok`

- [ ] **Step 3: lazygit が設定を受け付けることを確認する**

Run: `lazygit --config >/dev/null && echo "config ok"`
Expected: `config ok`

- [ ] **Step 4: 実機で確認する**

herdr のペイン内で `lazygit` を起動し、ファイルを選んで `e` を押す。
Expected: lazygit がサスペンドして同一ペインで nvim が開き、`:q` で lazygit に戻る

- [ ] **Step 5: コミット**

```bash
git add config/lazygit/config.yml
git commit -m "fix(lazygit): open editor in the same pane instead of a zellij float"
```

---

### Task 5: herdr 標準機能に吸収される fish 関数を削除する

**Files:**
- Delete: `config/fish/conf.d/zellij_tab.fish`
- Delete: `config/fish/functions/__zellij_tab_rename.fish`
- Delete: `config/fish/functions/agent-coding.fish`

**Interfaces:**
- Produces: `config/fish/` から zellij への参照が消える

- [ ] **Step 1: 3 ファイルを削除する**

herdr は workspace を cwd から自動命名し（実測: `"label":"dotfiles"`）、`[ui.sidebar.spaces]` の既定 rows が `[["state_icon","workspace"],["branch","git_status"]]` なのでリポジトリ名とブランチは標準で表示される。agent-coding のレイアウト起動は herdr 標準操作（`new_workspace` / `new_worktree` + 分割）に委ねる。

```bash
git rm config/fish/conf.d/zellij_tab.fish \
       config/fish/functions/__zellij_tab_rename.fish \
       config/fish/functions/agent-coding.fish
```

- [ ] **Step 2: 参照が残っていないことを確認する**

Run: `grep -rn -i "zellij\|agent-coding" config/ --exclude-dir=zellij`
Expected: `config/lazygit/agent-coding.yml`（凍結対象）以外に出力なし

- [ ] **Step 3: 旧リンクを掃除して張り直す**

`config/fish` はディレクトリ単位のリンクなので、削除は自動で反映される。念のため確認する。

```bash
./install.sh
test ! -e ~/.config/fish/conf.d/zellij_tab.fish && echo "removed"
```

Expected: `removed`

- [ ] **Step 4: fish が起動することを確認する**

Run: `fish -c 'echo shell ok'`
Expected: `shell ok`（削除した関数を参照するエラーが出ない）

- [ ] **Step 5: コミット**

```bash
git commit -m "chore(fish): drop zellij tab naming and agent-coding launcher"
```

---

### Task 6: herdr の設定を見直す

**Files:**
- Modify: `config/herdr/config.toml`

**Interfaces:**
- Produces: 既定アクションを潰していたキーが解消され、herdr 固有機能にキーが割り当たる

- [ ] **Step 1: config.toml を書き換える**

ファイル全体を次に置き換える。

```toml
onboarding = false

[theme]
# nvim (catppuccin-mocha) と gh-dash の配色に揃える。
name = "catppuccin"

[terminal]
default_shell = "fish"

[keys]
# Match the Zellij normal-mode workflow without intercepting pane input.
# prefix+shift+g / prefix+s / prefix+shift+tab は既定の
# new_worktree / settings / cycle_pane_previous に残す。
prefix = "ctrl+space"
goto = "prefix+space"
rename_workspace = "prefix+shift+comma"
open_notification_target = "prefix+shift+o"
reload_config = "prefix+shift+r"

# Workspaces, worktrees, and agents.
switch_workspace = "prefix+shift+1..9"
previous_workspace = "prefix+shift+k"
next_workspace = "prefix+shift+j"
open_worktree = "prefix+shift+e"
focus_agent = "prefix+alt+1..9"
previous_agent = "prefix+shift+h"
next_agent = "prefix+shift+l"

# Pane movement and operations.
focus_pane_left = ["prefix+h", "ctrl+shift+h"]
focus_pane_down = ["prefix+j", "ctrl+shift+j"]
focus_pane_up = ["prefix+k", "ctrl+shift+k"]
focus_pane_right = ["prefix+l", "ctrl+shift+l"]
split_horizontal = "prefix+minus"
split_vertical = "prefix+backslash"
close_pane = ["prefix+x", "ctrl+shift+x"]
zoom = ["prefix+f", "ctrl+shift+f"]
last_pane = "prefix+p"
resize_mode = "prefix+plus"

# Tabs, scrollback, and session control.
new_tab = ["prefix+t", "ctrl+shift+t"]
previous_tab = "ctrl+shift+tab"
next_tab = "ctrl+tab"
switch_tab = "prefix+1..9"
close_tab = ["prefix+shift+w", "ctrl+shift+w"]
edit_scrollback = "prefix+r"
detach = "prefix+d"

[[keys.command]]
key = "prefix+g"
command = "lazygit"
description = "run lazygit"
type = "popup"
width = "80%"
height = "80%"

[[keys.command]]
key = "prefix+e"
command = "nvim"
description = "run nvim"
type = "popup"
width = "80%"
height = "80%"

[[keys.command]]
key = "prefix+o"
command = "fish"
description = "open fish"
type = "popup"
width = "80%"
height = "80%"

[ui.sound]
enabled = true

[ui.toast]
delivery = "terminal"

[ui]
show_agent_labels_on_pane_borders = true

[experimental]
pane_history = true
```

変更点は次の 4 つ。

1. `goto` を `prefix+shift+g` から `prefix+space` へ移し、`prefix+shift+g` を既定の `new_worktree` に返す
2. `edit_scrollback` から `prefix+s` を、`previous_tab` から `prefix+shift+tab` を、`detach` から `ctrl+q` を外し、それぞれ既定の `settings` / `cycle_pane_previous` と fish の `bind \cq 'gwcd'` に返す
3. workspace / worktree / agent 系の 7 アクションを新規に割り当てる
4. `[theme] name` を明示し、`prefix+a`（agent-coding）のコメントアウト block を削除する

- [ ] **Step 2: 設定が受理されることを確認する**

Run: `herdr config check`
Expected: `config: ok`

- [ ] **Step 3: 新規キーが既定と衝突していないことを確認する**

`herdr config check` は既定値との衝突を検出しないため、目視で照合する。

Run: `herdr --default-config | grep -E "prefix\+(space|shift\+[hjkle])|prefix\+alt"`
Expected: `prefix+shift+e` / `prefix+shift+h` / `prefix+shift+j` / `prefix+shift+k` / `prefix+shift+l` / `prefix+space` を既定で使うアクションが無く、`focus_agent = "prefix+alt+1..9"` と `switch_workspace = "prefix+shift+1..9"` は推奨値としてコメントに載っている

- [ ] **Step 4: 稼働中の herdr に反映する**

Run: `herdr server reload-config`
Expected: エラーなし

- [ ] **Step 5: 実機でキーを確認する**

herdr のペイン内で順に押す。

| キー | 期待する動作 |
|---|---|
| `ctrl+space` → `space` | navigate（goto）モードが開く |
| `ctrl+space` → `shift+g` | worktree 作成のプロンプトが出る |
| `ctrl+space` → `s` | 設定画面が開く |
| `ctrl+q` | detach せず、fish の gwcd が起動する |
| `ctrl+space` → `shift+j` / `shift+k` | workspace を移動する |

- [ ] **Step 6: コミット**

```bash
git add config/herdr/config.toml
git commit -m "fix(herdr): stop shadowing default actions and bind herdr-native features"
```

---

### Task 7: CLAUDE.md を herdr 前提に更新する

**Files:**
- Modify: `CLAUDE.md:14-40`

**Interfaces:**
- Produces: リポジトリ概要とアーキテクチャ図が実態と一致する

- [ ] **Step 1: アーキテクチャ図の zellij 行を書き換える**

`CLAUDE.md` の `config/` ツリーのうち、`zellij` の行を次に置き換える。

```
├── zellij/      # Zellij設定（herdrへ移行・デプロイ対象外）
```

- [ ] **Step 2: herdr の説明を追記する**

同ツリーの `herdr/` 行はすでに存在するため変更不要。ツリー直後に次の 1 段落を追加する。

```markdown
マルチプレクサは herdr を使う。`config/fish/functions/__herdr_open_tab.fish` が
`herdr tab create` と `herdr pane run` をまとめており、lazygit・gh-dash から
新しいタブでコマンドを開く用途はすべてこの関数を経由する。
```

- [ ] **Step 3: 記述が実態と合っているか確認する**

```bash
grep -n "zellij\|herdr" CLAUDE.md
grep -n "COMMON_TARGETS" install.sh
```

Expected: CLAUDE.md の記述と `install.sh` の `COMMON_TARGETS`（`git ghostty fish nvim lazygit gh-dash herdr/config.toml`）が一致する

- [ ] **Step 4: コミット**

```bash
git add CLAUDE.md
git commit -m "docs: describe herdr as the primary multiplexer"
```

---

### Task 8: 実機検証と積み残しの確認

**Files:**
- Modify: `config/herdr/config.toml`（検証結果しだい）

**Interfaces:**
- Consumes: Task 6 までのすべての変更

- [ ] **Step 1: ターミナル依存のキーが届くか確認する**

ghostty は `ctrl+tab` を CSI シーケンスに変換している（`config/ghostty/config`: `keybind = ctrl+tab=esc:[27;5;9~`）。herdr がこれを解釈するかは実機でしか分からない。

herdr のペイン内で `ctrl+tab` / `ctrl+shift+tab` / `ctrl+shift+{h,j,k,l,x,f,t,w}` を押す。

Expected: それぞれタブ移動・ペイン移動などが起きる。

`ctrl+shift+{h,j,k,l,x,f,t,w}` は `focus_pane_*` / `close_pane` / `zoom` / `new_tab` / `close_tab` の副次バインドで、いずれも prefix 版（`prefix+hjkl` / `prefix+x` / `prefix+f` / `prefix+t` / `prefix+shift+w`）を持つため、届かなくても操作は失われない。

実害があるのはタブ移動の `ctrl+tab` / `ctrl+shift+tab` だけで、prefix 版が無い。届かない場合は `config/herdr/config.toml` を次のように変更する。`prefix+n` / `prefix+p` は既定の `next_tab` / `previous_tab` なので衝突せず、明け渡す `last_pane` は既定の `zoom` が空けた `prefix+z` に移す。

```toml
next_tab = ["ctrl+tab", "prefix+n"]
previous_tab = ["ctrl+shift+tab", "prefix+p"]
last_pane = "prefix+z"
```

- [ ] **Step 2: popup の cwd を確認する**

`[[keys.command]]` に `cwd` フィールドは存在しない（実測: `unknown config key keys.command.0.cwd`）。popup がどこで開くかは `[terminal] new_cwd` 任せになる。

herdr のペイン内で任意の git リポジトリに `cd` してから `ctrl+space` → `g` を押す。

Expected: そのリポジトリで lazygit が開く。ホームディレクトリなど別の場所で開いた場合は、`command` を次に変更する。

```toml
command = "cd \"$HERDR_ACTIVE_PANE_CWD\" && lazygit"
```

- [ ] **Step 3: claude の統合を入れるか判断する**

`herdr integration status` はすべて not installed で、`[session] resume_agents_on_restore`（既定 true）が機能しない状態にある。

Run: `herdr integration status`
Expected: `claude: not installed (/home/zyun/.claude/hooks/herdr-agent-state.sh)`

入れる場合は次を実行する。`~/.claude/hooks/` は dotfiles のデプロイ範囲外なので、リポジトリには含めない。

```bash
herdr integration install claude
herdr integration status
```

- [ ] **Step 4: 検証結果を反映した場合はコミット**

Step 1 か Step 2 で `config/herdr/config.toml` を変更した場合のみ実行する。

```bash
git add config/herdr/config.toml
git commit -m "fix(herdr): adjust bindings after on-device verification"
```

- [ ] **Step 5: 全体の最終確認**

```bash
./test.sh
herdr config check
grep -rn -i zellij config/ --exclude-dir=zellij
```

Expected: `14 passed, 0 failed` / `config: ok` / grep は `config/lazygit/agent-coding.yml` 以外に出力なし
