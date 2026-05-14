function gh-dash-prune-pr-worktrees -d 'Remove .worktrees/pr-* entries (and local branches) for merged or closed PRs'
    argparse 'repo-path=' 'dry-run' -- $argv
    or return 1

    set -l repo_path $_flag_repo_path
    if test -z "$repo_path"
        set repo_path (git rev-parse --show-toplevel 2>/dev/null)
    end
    if test -z "$repo_path"
        echo "gh-dash-prune-pr-worktrees: not inside a git repository" >&2
        return 1
    end

    set -l origin_url (git -C "$repo_path" remote get-url origin 2>/dev/null)
    set -l owner_repo (string replace -r '^.*github\.com[:/]([^/]+/[^/.]+?)(\.git)?$' '$1' -- $origin_url)
    if test -z "$owner_repo"
        echo "gh-dash-prune-pr-worktrees: could not infer owner/repo from origin ($origin_url)" >&2
        return 1
    end

    set -l wt_root "$repo_path/.worktrees"
    set -l worktrees (git -C "$repo_path" worktree list --porcelain | awk '/^worktree / { print $2 }')

    for wt in $worktrees
        if not string match -q "$wt_root/pr-*" -- $wt
            continue
        end

        set -l dir_name (path basename -- $wt)
        set -l pr_num (string match -gr '^pr-([0-9]+)-' -- $dir_name)
        test -n "$pr_num"; or continue

        set -l state (gh pr view $pr_num -R $owner_repo --json state 2>/dev/null | jq -r '.state')
        if test -z "$state"
            echo "skip: $wt (could not query PR #$pr_num)"
            continue
        end

        if test "$state" != MERGED -a "$state" != CLOSED
            continue
        end

        if set -q _flag_dry_run
            echo "would remove: $wt (state=$state)"
            continue
        end

        if git -C "$repo_path" worktree remove "$wt"
            echo "removed worktree: $wt (state=$state)"
            git -C "$repo_path" branch -D "gh-dash-pr/$pr_num" 2>/dev/null
            and echo "removed branch: gh-dash-pr/$pr_num"
        else
            echo "failed to remove: $wt (force required? use 'git worktree remove --force')" >&2
        end
    end
end
