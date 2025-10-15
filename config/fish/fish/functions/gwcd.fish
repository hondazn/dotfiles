function gwcd
    # git worktree list からブランチ名だけを抽出し、fzfに渡す
    # awkで最後の列($NF)を取得し、trで角括弧'[]'を削除
    set selected_branch (git worktree list | awk '{print $NF}' | tr -d '[]' | fzf --height 50% --reverse --header "移動したいブランチを選択" --ansi \
        --preview-window 'wrap' \
        --preview '
            # {}にはブランチ名だけが入っている
            set -l branch {}
            # ブランチ名を使って、対応する行をgrepし、パス(1列目)をawkで抽出
            set -l path (git worktree list | command grep "\[$branch\]" | awk "{print \$1}")
            
            # パスが見つかった場合のみプレビューを表示
            if test -n "$path"
                echo -e "\033[1;32mPath:\033[0m $path" # フルパスを緑色で表示
                echo "-----------------------------------"
                git -C $path --no-optional-locks status --short --branch
            end
        '
    )

    # ブランチが選択された場合
    if test -n "$selected_branch"
        # 選択されたブランチ名からパスを再度見つけ出して移動
        set selected_path (git worktree list | command grep "\[$selected_branch\]" | awk '{print $1}')
        if test -n "$selected_path"
            cd "$selected_path"
        end
    end
end
