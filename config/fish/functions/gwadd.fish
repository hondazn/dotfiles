# ~/.config/fish/functions/gwadd.fish に保存します

function gwadd
    # Gitリポジトリのルートディレクトリでなければエラー
    set -l root_dir (git rev-parse --show-toplevel)
    if test -z "$root_dir"
        echo "エラー: Gitリポジトリのディレクトリ内から実行してください。" >&2
        return 1
    end

    # 現在のディレクトリを保存し、あとで戻れるようにする
    set -l original_dir (pwd)
    cd "$root_dir"

    # 全ブランチのリストを取得
    set -l branches (git branch -a --format="%(refname:short)")

    # fzfでブランチを選択するか、新しいブランチ名を入力
    set -l selected_branch (echo "$branches" | fzf --height 50% --reverse \
        --header "ベースにするブランチを選択、または新しいブランチ名を入力してEnter")

    # fzfがキャンセルされた場合は終了
    if test -z "$selected_branch"
        echo "キャンセルされました。"
        cd "$original_dir" # 元のディレクトリに戻る
        return 0
    end

    # 提案するディレクトリ名を生成 (例: "origin/feature/hoge" -> "feature-hoge")
    set -l suggested_dirname (string replace -ra '^(origin/|heads/)' '' -- "$selected_branch" | string replace -r '[/\\?%*:|"<>]' '-')

    # ユーザーにディレクトリ名の入力を求める（デフォルト値付き）
    read -p "ワークツリーのディレクトリ名を入力してください (デフォルト: $suggested_dirname): " worktree_dirname
    if test -z "$worktree_dirname"
        set worktree_dirname "$suggested_dirname"
    end

    # ディレクトリが既に存在する場合はエラー
    if test -e "$worktree_dirname"
        echo "エラー: ディレクトリ '$worktree_dirname' は既に存在します。" >&2
        cd "$original_dir" # 元のディレクトリに戻る
        return 1
    end

    # 実行するコマンドを組み立て
    set -l cmd
    # 入力された名前が既存のブランチリストに含まれているかチェック
    if contains -- "$selected_branch" $branches
        # 既存ブランチの場合
        # 例: git worktree add <dir> feature/foo
        set cmd "git worktree add '$worktree_dirname' '$selected_branch'"
    else
        # 新しいブランチの場合
        # 例: git worktree add -b <new-branch> <dir>
        set cmd "git worktree add -b '$selected_branch' '$worktree_dirname'"
    end

    # コマンドを実行
    echo "実行コマンド: $cmd"
    if eval $cmd
        echo -e "\n✅ ワークツリーを \033[32m$root_dir/$worktree_dirname\033[0m に作成しました。"
        echo "   'gwcd' を使って移動できます。"
    else
        echo "❌ エラー: ワークツリーの作成に失敗しました。" >&2
    end

    # 最後に元のディレクトリに戻る
    cd "$original_dir"
end
