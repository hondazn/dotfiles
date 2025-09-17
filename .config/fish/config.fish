if status is-interactive
	# Commands to run in interactive sessions can go here
	tabs -4

	# CLI tools
	if test -e /opt/homebrew/bin/brew
		eval "$(/opt/homebrew/bin/brew shellenv)"
	else if test -e /home/linuxbrew/.linuxbrew/bin/brew
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	end
	# eval "$(/opt/homebrew/bin/brew shellenv)"
	eval "$(mise activate fish)"
	starship init fish | source
	# direnv hook fish | source

	# Alias
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

# pnpm
set -gx PNPM_HOME "/Users/sp_user/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
