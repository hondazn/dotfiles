{ pkgs, lib, ... }:
let
	username = "hondazn";
in 
{
	nixpkgs = {
		config.allowUnfree = true;
	};
	home.username = username;
	home.homeDirectory = lib.mkForce "/Users/${username}";
	home.packages = with pkgs; [
		home-manager
		rustup
		uv
		pnpm
		fish
		git
		mise
		devbox
		neovim
		ripgrep
		fd
		bat
		eza
		zoxide
		bottom
		jq
		ghq
		delta
		lazygit
		starship
		tokei
		topgrade
		ffmpeg
		imagemagick
		zellij
		ghostty-bin
		plemoljp
		colima
		skhd
		yabai
		shottr
		raycast
		slack
		vscode
		gh
		claude-code
		codex
	];
	programs.skim.enable = true;
	home.stateVersion = "25.05";
}
