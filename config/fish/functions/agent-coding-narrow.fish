function agent-coding-narrow -d 'Open narrow agent-coding layout with ghq repo selection'
    set -l repo (ghq list --full-path | sk --prompt "repo> ")
    test -n "$repo"; or return

    if test -n "$ZELLIJ"
        zellij action new-tab --layout agent-coding-narrow --cwd "$repo"
    else
        cd "$repo"
        zellij --layout agent-coding-narrow
    end
end
