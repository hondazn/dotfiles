if test -n "$ZELLIJ"
    function __zellij_tab_on_pwd --on-variable PWD
        __zellij_tab_rename
    end

    function __zellij_tab_on_postexec --on-event fish_postexec
        string match -rq '^git\s+(checkout|switch|pull|merge|rebase)' -- $argv[1]; or return
        __zellij_tab_rename
    end

    # 起動時にも実行
    __zellij_tab_rename
end
