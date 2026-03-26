function _tide_github_url
    set -l remote (git remote get-url origin 2>/dev/null)
    or return 1

    set -l url (string replace -r '^git@[^:]*github\.com:' 'https://github.com/' -- $remote |
        string replace -r '^ssh://git@[^/]*github\.com/' 'https://github.com/' |
        string replace -r '\.git$' '')

    string match -q 'https://github.com/*' -- $url
    or return 1

    echo $url
end
