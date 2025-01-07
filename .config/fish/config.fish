if status is-interactive
	# Commands to run in interactive sessions can go here

	tabs -4

	starship init fish | source
	fzf --fish | source

	# Git
	alias gst "git status --short --branch"
	alias glog "git log --oneline --decorate=short --date=format:'%Y-%m-%d %H:%M:%S' --pretty=format:'%Cgreen%h %C(yellow)%cd %Cred%d %Creset%s %Cblue<%cn>'"
	alias ggra "git log --graph --oneline --decorate=short --date=format:'%Y-%m-%d %H:%M:%S' --pretty=format:'%Cgreen%h %C(yellow)%cd %Cred%d %Creset%s %Cblue<%cn>'"
	alias gdifff "git diff --name-only"
	alias gdiffw "git diff --word-diff"
end

eval "$(/opt/homebrew/bin/mise activate fish)"
