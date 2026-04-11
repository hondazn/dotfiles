# Source Tide's original and save it under a different name (guard against double-source)
if not functions -q _tide_pwd_original
    source $__fish_config_dir/functions/_tide_pwd.fish
    functions --copy _tide_pwd _tide_pwd_original
end

function _tide_pwd
    if set -l _gh_url (_tide_github_url 2>/dev/null)
        set -l top (git rev-parse --show-toplevel 2>/dev/null)
        or begin
            _tide_pwd_original
            return
        end

        set -l rel (string replace -r "^"(string escape --style=regex $top) "" -- $PWD)
        set -l rel (string trim -l -c / -- $rel)
        set -l slug (string replace 'https://github.com/' '' -- $_gh_url)
        if test -n "$rel"
            set slug "$slug/$rel"
        end

        set_color -o $tide_pwd_color_anchors | read -l color_anchors
        set -l reset_to_color_dirs (set_color normal -b $tide_pwd_bg_color; set_color $tide_pwd_color_dirs)
        if test -w .
            set -l pwd_prefix $tide_pwd_icon' '
        else
            set -l pwd_prefix $tide_pwd_icon_unwritable' '
        end

        set -l segs (string split / -- $slug)
        set -l n (count $segs)
        set -l pieces
        for i in (seq $n)
            if test $i -eq 1
                set -a pieces "$reset_to_color_dirs$pwd_prefix$segs[$i]"
            else if test $i -eq $n
                set -a pieces "$color_anchors$segs[$i]$reset_to_color_dirs"
            else
                set -a pieces "$reset_to_color_dirs$segs[$i]"
            end
        end
        set -l pwd_text (string join / -- $pieces)

        string join / -- $pieces | string length -V | read -g _tide_pwd_len

        set -l pwd_restore (set_color normal -b $tide_pwd_bg_color; set_color $tide_pwd_color_dirs)
        printf '\e]8;;%s\e\\' "$_gh_url"
        printf '%s%s' $pwd_restore $pwd_text
        printf '\e]8;;\e\\'
    else
        _tide_pwd_original
    end
end
