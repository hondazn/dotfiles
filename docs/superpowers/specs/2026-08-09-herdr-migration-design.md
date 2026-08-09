# zellij → herdr 移行 設計

作成日: 2026-08-09 / 対象: herdr v0.8.0

## 背景

マルチプレクサのメインを zellij から herdr に乗り換える。作業中の差分では `config/herdr/config.toml` の追加と `install.sh` のネストパス対応まで済んでいるが、zellij に依存した設定が他に 7 箇所残っている。あわせて、zellij のキー設定をそのまま移植した herdr 設定の妥当性も見直す。

## 決定事項

| 論点 | 決定 |
|---|---|
| zellij の扱い | 設定は残すがデプロイ対象外（alacritty / tmux と同じ扱い） |
| `run --floating` の代替 | 用途別に再設計。原則は新タブ、待ちが必要な lazygit のエディタ呼び出しのみ同一ペイン |
| PR レビュー系 | copilot / octo の gh-dash キーは削除。nvim / shell は同じ workspace の新タブ |
| タブ名自動更新 | 廃止し herdr 標準表示に任せる |
| agent-coding | 廃止し herdr 標準操作に任せる |
| キー設定 | 衝突を修正し、herdr 固有機能にキーを割り当てる |
| `ctrl+q` | fish の gwcd を優先。herdr の detach から外す |

## 変更一覧

### 削除

| パス | 理由 |
|---|---|
| `config/fish/conf.d/zellij_tab.fish` | workspace の自動命名と sidebar の `branch` / `git_status` が herdr 標準 |
| `config/fish/functions/__zellij_tab_rename.fish` | 同上 |
| `config/fish/functions/agent-coding.fish` | herdr 標準操作に委ねる |
| `config/fish/functions/gh-dash-pr-copilot.fish` | レビュー用途を廃止 |

### 凍結（触らない）

`config/zellij/` 一式と `config/lazygit/agent-coding.yml` は現状のまま残す。後者は zellij の agent-coding レイアウトからのみ参照される設定で、片方だけ消すと zellij に戻したときに壊れる。`config/lazygit/` はデプロイされ続けるが、レイアウトが `-ucf` で明示しない限り読まれない。

### 書き換え

| パス | 内容 |
|---|---|
| `config/fish/functions/gh-dash-pr-nvim.fish` | `zellij run --floating` → `__herdr_open_tab` |
| `config/fish/functions/gh-dash-pr-shell.fish` | 同上 |
| `config/gh-dash/config.yml` | `D` を新タブ化、`C` / `O` を削除 |
| `config/lazygit/config.yml` | `editInTerminal: true` に切り替え、`os.edit` / `editAtLine` / `editAtLineAndWait` は nvim を直接呼ぶ |
| `config/herdr/config.toml` | 後述 |
| `install.sh` | `COMMON_TARGETS` から `zellij` を除去 |
| `CLAUDE.md` | アーキテクチャ図と本文を herdr 前提に更新 |

### 追加

`config/fish/functions/__herdr_open_tab.fish`

herdr の CLI には「コマンドを実行して終了時に閉じる」属性がないため、`tab create` の返り値から `pane_id` を取り、`pane run "<cmd>; exit"` する手順をこの 1 本に閉じ込める。

- `$HERDR_ENV` を検証し、herdr 外なら失敗する
- `--cwd` / `--label` / `--focus` を受ける（既定は `--no-focus`）
- `$HERDR_WORKSPACE_ID` の workspace にタブを作る

## herdr 設定の修正

### キー衝突の解消

`herdr config check` は既定値との衝突を検出しない（実測: `[[keys.command]] key = "prefix+b"` は既定の `toggle_sidebar` と同じだが `config: ok`）。現行設定では以下が片方しか動作しない。

| アクション | 現行 | 修正後 |
|---|---|---|
| `goto` | `prefix+shift+g` | `prefix+space` |
| `new_worktree` | 潰れている | `prefix+shift+g`（既定に復帰） |
| `edit_scrollback` | `prefix+r`, `prefix+s` | `prefix+r` のみ |
| `settings` | 潰れている | `prefix+s`（既定に復帰） |
| `previous_tab` | `prefix+shift+tab`, `ctrl+shift+tab` | `ctrl+shift+tab` のみ |
| `cycle_pane_previous` | 潰れている | `prefix+shift+tab`（既定に復帰） |
| `detach` | `prefix+d`, `ctrl+q` | `prefix+d` のみ |

`ctrl+q` は prefix なしの直接バインドのため常時インターセプトされ、`config/fish/config.fish:44` の `bind \cq 'gwcd'` が発火しなくなる。zellij では locked モード中にペインへ素通りしていた。

### herdr 固有機能の割当

| アクション | キー |
|---|---|
| `switch_workspace` | `prefix+shift+1..9` |
| `focus_agent` | `prefix+alt+1..9` |
| `previous_workspace` / `next_workspace` | `prefix+shift+k` / `prefix+shift+j` |
| `previous_agent` / `next_agent` | `prefix+shift+h` / `prefix+shift+l` |
| `open_worktree` | `prefix+shift+e` |
| `remove_worktree` | 割り当てない（破壊操作のため UI / CLI 経由） |

### その他

- `[[keys.command]]` の `prefix+a`（agent-coding）コメントアウト block を削除
- `[theme] name = "catppuccin"` を明示。nvim（catppuccin-mocha）と gh-dash の配色に揃え、既定値の変更に影響されないようにする

## 実機検証項目

コード変更では確認できず、実際にキーを押す必要があるもの。

1. ghostty の `keybind = ctrl+tab=esc:[27;5;9~` 経由で herdr が `ctrl+tab` / `ctrl+shift+tab` を認識するか。タブ移動はこの 2 キーにしか割り当てておらず、届かないと代替手段がない
2. `ctrl+shift+{h,j,k,l,x,f,t,w}` が herdr に届くか。いずれも prefix 版を併せ持つため、届かなくても操作は失われない
3. popup の lazygit がどの cwd で開くか。`[[keys.command]]` に `cwd` フィールドは存在しないため、想定外なら `command` 内で `$HERDR_ACTIVE_PANE_CWD` を使う
4. `herdr integration install claude` の実行可否。`~/.claude/hooks/` 配下で dotfiles のデプロイ範囲外のため、手順として記録するに留める

## 根拠

herdr v0.8.0 のバイナリに対して実行した結果。

```
# 新タブでコマンドを実行し、終了時に自動で閉じる
$ herdr tab create --workspace wS --cwd /tmp --label probe --no-focus
{"result":{"root_pane":{"pane_id":"wS:p2"},"tab":{"tab_id":"wS:t2"}}}
$ herdr pane run wS:p2 "echo PROBE_OK; exit"
$ herdr tab list --workspace wS
[('wS:t1', '1')]

# 既定値との衝突は検出されない
$ printf '[keys]\nprefix="ctrl+b"\n\n[[keys.command]]\nkey="prefix+b"\ntype="popup"\ncommand="lazygit"\n' > t6.toml
$ HERDR_CONFIG_PATH=t6.toml herdr config check
config: ok

# 明示した同士の衝突は検出される
$ HERDR_CONFIG_PATH=t4.toml herdr config check
config: issues found
prefix+shift+g: kept keys.new_worktree, disabled keys.goto

# keys.command に cwd フィールドはない
$ HERDR_CONFIG_PATH=t7.toml herdr config check
config: issues found
unknown config key keys.command.0.cwd; ignoring key

# 上表の新キーマップ一式は構文として受理される
$ HERDR_CONFIG_PATH=t9.toml herdr config check
config: ok

# workspace は cwd から自動命名され、カスタムトークンを持てる
$ herdr workspace get wS
{"workspace":{"label":"dotfiles","tokens":{"issue":"999"}}}
```

CLI には floating / popup を開く手段がない。`herdr plugin pane open --placement` は `overlay` / `split` / `tab` / `zoomed` のみで、かつプラグイン所有ペイン専用。popup は `[[keys.command]] type = "popup"` すなわちキーバインド経由に限られる。

lazygit の `editInTerminal` はコマンド個別ではなく全体設定であり、「lazygit がエディタ呼び出し前に自身をサスペンドするか」を決める（[Config.md](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md)）。`editAtLineAndWait` だけを同期にする分岐は書けないため、3 つとも同一ペインに統一する。
