# Source Tide's original and save it under a different name (guard against double-source)
if not functions -q _tide_pwd_original
    source $__fish_config_dir/functions/_tide_pwd.fish
    functions --copy _tide_pwd _tide_pwd_original
end

# Wrapper: add OSC 8 hyperlink to GitHub repo page
function _tide_pwd
    set -l output (_tide_pwd_original)
    # _tide_pwd_len is already set as global by Tide's function

    if set -l _gh_url (_tide_github_url 2>/dev/null)
        set -l _osc8_open (printf '\e]8;;%s\e\\' "$_gh_url")
        set -l _osc8_close (printf '\e]8;;\e\\')
        echo -ns $_osc8_open$output$_osc8_close
    else
        echo -ns $output
    end
end
