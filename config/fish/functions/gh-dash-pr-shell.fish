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
