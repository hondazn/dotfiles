function __zellij_tab_rename
    test -n "$ZELLIJ"; or return

    set -l repo (git remote get-url origin 2>/dev/null | string replace -r '.*[:/]([^/]+?)(?:\.git)?$' '$1')

    if test -z "$repo"
        zellij action rename-tab (basename $PWD)
        return
    end

    set -l branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
    set -l issue (string match -rg '(?:^|/)(\d+)' -- $branch)

    if test -n "$issue"
        zellij action rename-tab "$repo #$issue"
    else
        zellij action rename-tab "$repo $branch"
    end
end
