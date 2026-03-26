if status is-interactive
	# Custom function overrides take precedence over plugin-managed functions/
	set -g fish_function_path $__fish_config_dir/tide_custom $fish_function_path

	# Commands to run in interactive sessions can go here
	tabs -4

	# Environment variables
	set -gx FZF_DEFAULT_OPTS --height 40%
	set -gx FZF_DISABLE_KEYBINDINGS 0
	set -gx FZF_LEGACY_KEYBINDINGS 1
	set -gx FZF_PREVIEW_DIR_CMD ls
	set -gx FZF_PREVIEW_FILE_CMD "head -n 10"
	set -gx FZF_TMUX_HEIGHT 40%
	set -gx VIRTUAL_ENV_DISABLE_PROMPT true

	# CLI tools
	if test -e /opt/homebrew/bin/brew
		eval "$(/opt/homebrew/bin/brew shellenv)"
	else if test -e /home/linuxbrew/.linuxbrew/bin/brew
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	end
	eval "$(mise activate fish)"
	sk --shell fish | source
	source "$HOME/.cargo/env.fish"

	# PATH settings
	set -gx PATH $HOME/.local/bin $PATH
	set -gx PATH $HOME/bin $PATH
	set -gx EDITOR nvim

	# Alias
	alias ll "eza -la --color=always --group-directories-first --icons"
	alias la "eza -a --color=always --group-directories-first --icons"
	alias gst "git status --short --branch"
	alias glog "git log --oneline --decorate=short --date=format:'%Y-%m-%d %H:%M:%S' --pretty=format:'%Cgreen%h %C(yellow)%cd %Cred%d %Creset%s %Cblue<%cn>'"
	alias ggra "git log --graph --oneline --decorate=short --date=format:'%Y-%m-%d %H:%M:%S' --pretty=format:'%Cgreen%h %C(yellow)%cd %Cred%d %Creset%s %Cblue<%cn>'"
	alias gdifff "git diff --name-only"
	alias gdiffw "git diff --word-diff"

	alias tailscale "/Applications/Tailscale.app/Contents/MacOS/Tailscale"
	alias beep "afplay /System/Library/Sounds/Blow.aiff"

	# key bindings
	bind \cq 'gwcd; commandline -f repaint'
end
