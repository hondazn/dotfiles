# Prepend before config.fish so tide_custom autoloads before any prompt/snippet runs.
set -g fish_function_path $__fish_config_dir/tide_custom $fish_function_path
