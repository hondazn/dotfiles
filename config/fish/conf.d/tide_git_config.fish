# Tide git segment customization (catppuccin-mocha pill badges)
# Survives fisher update — conf.d overrides autoloaded functions on shell startup

# Branch name segment: state background
set -g tide_git_bg_color 4E9A06
set -g tide_git_bg_color_unstable C4A000
set -g tide_git_bg_color_urgent CC0000

# Allow longer branch names (default: 24)
set -g tide_git_truncation_length 48

# Remove newline from items — _tide_item_git handles it directly
set -g _tide_left_items pwd git character

# Override _tide_item_git: branch segment + pill badges + newline
functions -e _tide_item_git
function _tide_item_git
    if git branch --show-current 2>/dev/null | string shorten -"$tide_git_truncation_strategy"m$tide_git_truncation_length | read -l location
        git rev-parse --git-dir --is-inside-git-dir | read -fL gdir in_gdir
        set location $_tide_location_color$location
    else if test $pipestatus[1] != 0
        return
    else if git tag --points-at HEAD | string shorten -"$tide_git_truncation_strategy"m$tide_git_truncation_length | read location
        git rev-parse --git-dir --is-inside-git-dir | read -fL gdir in_gdir
        set location '#'$_tide_location_color$location
    else
        git rev-parse --git-dir --is-inside-git-dir --short HEAD | read -fL gdir in_gdir location
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

    # Branch name segment
    _tide_print_item git $_tide_location_color$tide_git_icon' ' (set_color white; echo -ns $location
        if test -n "$operation"
            echo -ns ' '$operation
            if test -n "$step"; echo -ns ' '$step/$total_steps; end
        end)

    # Close segment + newline
    set_color $tide_git_bg_color -b normal
    if test -n "$behind$ahead$stash$conflicted$staged$dirty$untracked"
        echo -ns $tide_left_prompt_suffix
        if test -n "$behind";     set_color 89B4FA -b normal; echo -ns \ue0b6; set_color 1E1E2E -b 89B4FA; echo -ns $behind; set_color 89B4FA -b normal; echo -ns \ue0b4; end
        if test -n "$ahead";      set_color 89B4FA -b normal; echo -ns \ue0b6; set_color 1E1E2E -b 89B4FA; echo -ns $ahead; set_color 89B4FA -b normal; echo -ns \ue0b4; end
        if test -n "$stash";      set_color CBA6F7 -b normal; echo -ns \ue0b6; set_color 1E1E2E -b CBA6F7; echo -ns $stash; set_color CBA6F7 -b normal; echo -ns \ue0b4; end
        if test -n "$conflicted"; set_color F38BA8 -b normal; echo -ns \ue0b6; set_color 1E1E2E -b F38BA8; echo -ns $conflicted; set_color F38BA8 -b normal; echo -ns \ue0b4; end
        if test -n "$staged";     set_color A6E3A1 -b normal; echo -ns \ue0b6; set_color 1E1E2E -b A6E3A1; echo -ns $staged; set_color A6E3A1 -b normal; echo -ns \ue0b4; end
        if test -n "$dirty";      set_color FAB387 -b normal; echo -ns \ue0b6; set_color 1E1E2E -b FAB387; echo -ns $dirty; set_color FAB387 -b normal; echo -ns \ue0b4; end
        if test -n "$untracked";  set_color 6C7086 -b normal; echo -ns \ue0b6; set_color CDD6F4 -b 6C7086; echo -ns $untracked; set_color 6C7086 -b normal; echo -ns \ue0b4; end
        echo
    else
        echo $tide_left_prompt_suffix
    end
    set -g add_prefix
end
