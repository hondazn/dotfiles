function agent-coding -d 'Open agent-coding layout with ghq repo selection'
    set -l repo (ghq list --full-path | sk --prompt "repo> ")
    test -n "$repo"; or return

    if test -n "$ZELLIJ"
        zellij action new-tab --layout agent-coding --cwd "$repo"
        zellij action switch-mode normal
    else
        cd "$repo"
        zellij --layout agent-coding
    end
end
