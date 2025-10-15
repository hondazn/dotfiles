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
		tree-sitter
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
		karabiner-elements
		ice-bar
		scroll-reverser
		raycast
		yabai
		shottr
		slack
		vscode
		gh
		claude-code
		codex
		tailscale
	];

	xdg.configFile."home-manager/home.nix".source = ./home.nix;
	xdg.configFile."nvim".source = ../../config.nvim;
	xdg.configFile."fish".source = ../.config/fish;
	xdg.configFile."git".source = ../.config/git;
	xdg.configFile."lazygit".source = ../.config/lazygit;
	xdg.configFile."zellij".source = ../.config/zellij;
	xdg.configFile."ghostty".source = ../.config/ghostty;
	xdg.configFile."skhd".source = ../.config/skhd;
	xdg.configFile."yabai".source = ../.config/yabai;

	home.stateVersion = "25.05";
}
