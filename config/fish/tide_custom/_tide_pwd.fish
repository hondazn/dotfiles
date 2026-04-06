# Source Tide's original and save it under a different name (guard against double-source)
if not functions -q _tide_pwd_original
    source $__fish_config_dir/functions/_tide_pwd.fish
    functions --copy _tide_pwd _tide_pwd_original
end

function _tide_pwd
    if set -l _gh_url (_tide_github_url 2>/dev/null)
        set -l output (_tide_pwd_original)
        # OSC 8 hyperlink opener resets SGR on some terminals; re-apply pwd segment colors.
        set -l pwd_restore (set_color normal -b $tide_pwd_bg_color; set_color $tide_pwd_color_dirs)
        printf '\e]8;;%s\e\\' "$_gh_url"
        echo -ns $pwd_restore$output
        printf '\e]8;;\e\\'
    else
        # Avoid extra command substitution so colors match stock Tide.
        _tide_pwd_original
    end
end
