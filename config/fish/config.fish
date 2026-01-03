if status is-interactive
	# Commands to run in interactive sessions can go here
	tabs -4

	# CLI tools
	if test -e /opt/homebrew/bin/brew
		eval "$(/opt/homebrew/bin/brew shellenv)"
	else if test -e /home/linuxbrew/.linuxbrew/bin/brew
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	end
	eval "$(mise activate fish)"
	starship init fish | source
	sk --shell fish | source
	source "$HOME/.cargo/env.fish"

	# PATH settings
	set -gx PATH $HOME/.local/bin $PATH
	set -gx PATH $HOME/bin $PATH
	set -gx EDITOR nvim
	set -gx CLAUDE_CONFIG_DIR $HOME/.config/claude

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
