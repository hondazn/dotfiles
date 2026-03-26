# Tide git configuration
# Allow longer branch names (default: 24)
if test "$tide_git_truncation_length" != 48
    set -U tide_git_truncation_length 48
end
