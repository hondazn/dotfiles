function _tide_item_git_custom
    if git branch --show-current 2>/dev/null | string shorten -"$tide_git_truncation_strategy"m$tide_git_truncation_length | read -l location
        git rev-parse --git-dir --is-inside-git-dir | read -fL gdir in_gdir
        set -f raw_ref $location
        set -f ref_type branch
        set location $_tide_location_color$location
    else if test $pipestatus[1] != 0
        return
    else if git tag --points-at HEAD | string shorten -"$tide_git_truncation_strategy"m$tide_git_truncation_length | read location
        git rev-parse --git-dir --is-inside-git-dir | read -fL gdir in_gdir
        set -f raw_ref $location
        set -f ref_type tag
        set location '#'$_tide_location_color$location
    else
        git rev-parse --git-dir --is-inside-git-dir --short HEAD | read -fL gdir in_gdir location
        set -f raw_ref $location
        set -f ref_type commit
        set location @$_tide_location_color$location
    end

    if test -d $gdir/rebase-merge
        if not path is -v $gdir/rebase-merge/{msgnum,end}
            read -f step <$gdir/rebase-merge/msgnum
            read -f total_steps <$gdir/rebase-merge/end
        end
        test -f $gdir/rebase-merge/interactive && set -f operation rebase-i || set -f operation rebase-m
    else if test -d $gdir/rebase-apply
        if not path is -v $gdir/rebase-apply/{next,last}
            read -f step <$gdir/rebase-apply/next
            read -f total_steps <$gdir/rebase-apply/last
        end
        if test -f $gdir/rebase-apply/rebasing
            set -f operation rebase
        else if test -f $gdir/rebase-apply/applying
            set -f operation am
        else
            set -f operation am/rebase
        end
    else if test -f $gdir/MERGE_HEAD
        set -f operation merge
    else if test -f $gdir/CHERRY_PICK_HEAD
        set -f operation cherry-pick
    else if test -f $gdir/REVERT_HEAD
        set -f operation revert
    else if test -f $gdir/BISECT_LOG
        set -f operation bisect
    end

    test $in_gdir = true && set -l _set_dir_opt -C $gdir/..
    set -l stat (git $_set_dir_opt --no-optional-locks status --porcelain 2>/dev/null)
    string match -qr '(0|(?<stash>.*))\n(0|(?<conflicted>.*))\n(0|(?<staged>.*))
(0|(?<dirty>.*))\n(0|(?<untracked>.*))(\n(0|(?<behind>.*))\t(0|(?<ahead>.*)))?' \
        "$(git $_set_dir_opt stash list 2>/dev/null | count
        string match -r ^UU $stat | count
        string match -r ^[ADMR] $stat | count
        string match -r ^.[ADMR] $stat | count
        string match -r '^\?\?' $stat | count
        git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null)"

    if test -n "$operation$conflicted"
        set -g tide_git_bg_color $tide_git_bg_color_urgent
    else if test -n "$staged$dirty$untracked"
        set -g tide_git_bg_color $tide_git_bg_color_unstable
    end

    if set -l _gh_url (_tide_github_url 2>/dev/null)
        if test "$ref_type" = commit
            set -f _link_url "$_gh_url/commit/$raw_ref"
        else if test "$ref_type" = branch && set -l _m (string match -r '(?:^|[/_-])(\d+)' -- $raw_ref)
            set -f _link_url "$_gh_url/issues/$_m[2]"
        else
            set -f _link_url "$_gh_url/tree/$raw_ref"
        end
        set location (_tide_osc8_wrap "$_link_url" "$location")
    end

    _tide_print_item git $_tide_location_color$tide_git_icon' ' (set_color white; echo -ns $location
        if test -n "$operation"
            echo -ns ' '$operation
            if test -n "$step"; echo -ns ' '$step/$total_steps; end
        end)

    set -g _tide_git_badge_behind "$behind"
    set -g _tide_git_badge_ahead "$ahead"
    set -g _tide_git_badge_stash "$stash"
    set -g _tide_git_badge_conflicted "$conflicted"
    set -g _tide_git_badge_staged "$staged"
    set -g _tide_git_badge_dirty "$dirty"
    set -g _tide_git_badge_untracked "$untracked"
end

# Override _tide_item_newline from _tide_2_line_prompt.fish
# Renders segment suffix, then catppuccin pill badges, then newline
function _tide_item_newline
    set_color $prev_bg_color -b normal
    v=tide_"$_tide_side"_prompt_suffix echo -ns $$v

    # Catppuccin-mocha pill badges: name symbol fg_color bg_color
    set -l _badge_defs \
        behind '⇣' 1E1E2E 89B4FA \
        ahead '⇡' 1E1E2E 89B4FA \
        stash '*' 1E1E2E CBA6F7 \
        conflicted '~' 1E1E2E F38BA8 \
        staged '+' 1E1E2E A6E3A1 \
        dirty '!' 1E1E2E FAB387 \
        untracked '?' CDD6F4 6C7086
    for i in (seq 1 4 (count $_badge_defs))
        set -l name $_badge_defs[$i]
        set -l symbol $_badge_defs[(math $i + 1)]
        set -l fg $_badge_defs[(math $i + 2)]
        set -l bg $_badge_defs[(math $i + 3)]
        set -l var _tide_git_badge_$name
        if test -n "$$var"
            set_color $bg -b normal; echo -ns \ue0b6
            set_color $fg -b $bg; echo -ns $symbol$$var
            set_color $bg -b normal; echo -ns \ue0b4
        end
    end
    set -e _tide_git_badge_behind _tide_git_badge_ahead _tide_git_badge_stash _tide_git_badge_conflicted _tide_git_badge_staged _tide_git_badge_dirty _tide_git_badge_untracked

    echo
    set -g add_prefix
end
