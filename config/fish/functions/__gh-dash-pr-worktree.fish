function __gh-dash-pr-worktree -d 'Ensure a PR worktree exists under <repo>/.worktrees and echo its path'
    argparse 'repo=' 'pr=' 'repo-path=' 'head-ref=' -- $argv
    or return 1

    for flag in _flag_repo _flag_pr _flag_repo_path _flag_head_ref
        if test -z "$$flag"
            echo "__gh-dash-pr-worktree: missing required flag for $flag" >&2
            return 1
        end
    end

    set -l repo_path $_flag_repo_path
    if string match -qr '^~/' -- $repo_path
        set repo_path (string replace -r '^~' $HOME -- $repo_path)
    end

    if not test -e "$repo_path/.git"
        echo "__gh-dash-pr-worktree: not a git repository: $repo_path" >&2
        return 1
    end

    set -l safe_ref (string replace -ra '[^A-Za-z0-9._-]' '-' -- $_flag_head_ref)
    set -l worktree_path "$repo_path/.worktrees/pr-$_flag_pr-$safe_ref"
    set -l local_branch "gh-dash-pr/$_flag_pr"

    if git -C "$repo_path" worktree list --porcelain | string match -q "worktree $worktree_path"
        echo $worktree_path
        return 0
    end

    if not git -C "$repo_path" fetch --quiet origin "+refs/pull/$_flag_pr/head:refs/heads/$local_branch"
        echo "__gh-dash-pr-worktree: failed to fetch refs/pull/$_flag_pr/head" >&2
        return 1
    end

    mkdir -p "$repo_path/.worktrees"
    if not git -C "$repo_path" worktree add "$worktree_path" "$local_branch"
        echo "__gh-dash-pr-worktree: failed to add worktree at $worktree_path" >&2
        return 1
    end

    echo $worktree_path
end
