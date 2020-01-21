# exit
alias x "exit"

# ls
alias l "exa"
alias la "exa -a"
alias ll "exa -lh"
alias lla "exa -lha"

# Git
alias gst "git status --short --branch"
alias glog "git log --oneline --decorate=short --date=format:'%Y-%m-%d %H:%M:%S' --pretty=format:'%Cgreen%h %C(yellow)%cd %Cred%d %Creset%s %Cblue<%cn>'"
alias ggra "git log --graph --oneline --decorate=short --date=format:'%Y-%m-%d %H:%M:%S' --pretty=format:'%Cgreen%h %C(yellow)%cd %Cred%d %Creset%s %Cblue<%cn>'"
alias gdifff "git diff --name-only"
alias gdiffw "git diff --word-diff"

alias untar "tar -zxvf"
alias getpass "openssl rand -base64 20"
alias sha "shasum -a 256"

rbenv init - | source

# phpbrew
source ~/.phpbrew/phpbrew.fish
set -g fish_user_paths "/usr/local/opt/icu4c/bin" $fish_user_paths
set -g fish_user_paths "/usr/local/opt/icu4c/sbin" $fish_user_paths
set -g fish_user_paths "/usr/local/opt/libxml2/bin" $fish_user_paths
set -g fish_user_paths "/usr/local/opt/openssl/bin" $fish_user_paths
set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
