# rg --hyperlink-format=kitty が出す file://<host><path>#<line> を受け付ける。
# eza などが出す行番号なしの file://<host><path> も同じ形の特殊例として扱う。
set -l parts (string match -rg '^file://[^/]*(/[^#]*)(?:#(\d+))?$' -- $HERDR_PLUGIN_CLICKED_URL)
or begin
    echo "open-in-nvim: unsupported url: $HERDR_PLUGIN_CLICKED_URL" >&2
    exit 1
end

set -l file (string unescape --style=url -- $parts[1])
set -l cwd (path dirname -- $file)
test -d $file; and set cwd $file

set -l cmd nvim
test -n "$parts[2]"; and set -a cmd +$parts[2]
__herdr_open_tab --focus --cwd $cwd --label (path basename -- $file) $cmd -- (string escape -- $file)
