function __ghq_list_all -d 'List all ghq repos and their worktrees'
    set -l repos (ghq list --full-path)
    begin
        printf '%s\n' $repos
        for repo in $repos
            if test -d "$repo/.git/worktrees"
                git -C "$repo" worktree list --porcelain 2>/dev/null \
                    | string match 'worktree *' \
                    | string replace 'worktree ' ''
            end
        end
    end | sort -u
end
