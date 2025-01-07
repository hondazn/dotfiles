# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# MacOSとLinuxで設定分岐
if [[ $(uname -s) == "Darwin" ]]; then
	# MacOSの場合
	# Homebrewのパスを通す
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
	eval "$(/opt/homebrew/bin/brew shellenv)"
else if [[ $(uname -s) == "Linux" ]]; then
	# Linuxの場合
	# Homebrewのパスを通す
	echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bash_profile
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Install CLI tools
brew install tmux git fish vim neovim mise ghq fzf fisher
brew install ripgrep fd git-delta lazygit

# Install fish tools
fish -c "fisher install jorgebucaran/fisher"
fish -c "fisher install fisherman/fzf"
fish -c "fisher install decors/fish-ghq"
