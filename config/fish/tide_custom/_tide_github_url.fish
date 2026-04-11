function _tide_github_url
    if test "$_tide_github_url_pwd" = "$PWD"
        test -n "$_tide_github_url_cache" && echo $_tide_github_url_cache
        return $_tide_github_url_status
    end
    set -g _tide_github_url_pwd $PWD

    set -l remote (git remote get-url origin 2>/dev/null)
    or begin
        set -g _tide_github_url_cache ""
        set -g _tide_github_url_status 1
        return 1
    end

    set -l url (string replace -r '^git@[^:]*github\.com:' 'https://github.com/' -- $remote |
        string replace -r '^ssh://git@[^/]*github\.com/' 'https://github.com/' |
        string replace -r '\.git$' '')

    if string match -q 'https://github.com/*' -- $url
        set -g _tide_github_url_cache $url
        set -g _tide_github_url_status 0
        echo $url
    else
        set -g _tide_github_url_cache ""
        set -g _tide_github_url_status 1
        return 1
    end
end
