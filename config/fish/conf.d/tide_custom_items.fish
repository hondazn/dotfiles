# Replace 'git' with 'git_custom' in tide prompt items (universal so subprocesses see it)
# git_custom adds OSC 8 hyperlinks and catppuccin pill badges
# Resilient to tide configure resetting the list back to 'git'
if set -l idx (contains -i git $_tide_left_items)
    set -U _tide_left_items $_tide_left_items[1..(math $idx - 1)] git_custom $_tide_left_items[(math $idx + 1)..]
end
