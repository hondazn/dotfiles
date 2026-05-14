function gh-dash-pr-copilot -d 'Open a one-shot Copilot PR review in a new zellij tab (worktree-based)'
    argparse 'repo=' 'pr=' 'repo-path=' 'head-ref=' -- $argv
    or return 1

    if test -z "$ZELLIJ"
        echo "gh-dash-pr-copilot: must be run inside zellij" >&2
        return 1
    end

    set -l wt (__gh-dash-pr-worktree \
        --repo $_flag_repo \
        --pr $_flag_pr \
        --repo-path $_flag_repo_path \
        --head-ref $_flag_head_ref)
    or return 1

    set -l pr_meta (gh pr view $_flag_pr -R $_flag_repo --json url,title | jq -r '.url, .title')
    or return 1

    set -l pr_url $pr_meta[1]
    set -l pr_title $pr_meta[2]
    set -l tab_name "copilot #$_flag_pr"
    set -l prompt "/pr-review $pr_url

repository: $_flag_repo
pr: #$_flag_pr
title: $pr_title
head branch: $_flag_head_ref
worktree: $wt"

    zellij action new-tab --name "$tab_name" --cwd "$wt" -- \
        copilot --allow-all --enable-all-github-mcp-tools -p "$prompt"
end
