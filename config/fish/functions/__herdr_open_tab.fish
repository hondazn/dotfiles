function __herdr_open_tab -d 'Run a command in a new herdr tab that closes when the command exits'
    argparse 'cwd=' 'label=' 'focus' -- $argv
    or return 1

    if test -z "$HERDR_ENV"
        echo "__herdr_open_tab: must be run inside herdr" >&2
        return 1
    end

    if test (count $argv) -eq 0
        echo "__herdr_open_tab: no command given" >&2
        return 1
    end

    set -l opts --workspace $HERDR_WORKSPACE_ID
    set -q _flag_cwd; and set -a opts --cwd $_flag_cwd
    set -q _flag_label; and set -a opts --label $_flag_label
    if set -q _flag_focus
        set -a opts --focus
    else
        set -a opts --no-focus
    end

    set -l pane (herdr tab create $opts | jq -r '.result.root_pane.pane_id')
    if test -z "$pane" -o "$pane" = null
        echo "__herdr_open_tab: failed to create tab" >&2
        return 1
    end

    # herdr にはコマンド終了時にペインを閉じる属性がないため exit を足す。
    herdr pane run $pane (string join ' ' -- $argv)"; exit"
end
