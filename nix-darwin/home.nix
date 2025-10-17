# home.nix
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
		dotter
		rustup
		uv
		pnpm
		fish
		git
		mise
		devbox
		neovim
		neovide
		ripgrep
		fd
		skim
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
		docker
		colima
		ice-bar
		raycast
		shottr
		slack
		vscode
		gh
		awscli
		claude-code
		codex
		tailscale
		_1password-gui
		_1password-cli
	];

	home.activation = {
		linkApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
			${pkgs.coreutils}/bin/ln -sfn "$HOME/.nix-profile/Applications" "$HOME/Applications/Nix Apps"
		'';
	};

	home.stateVersion = "25.05";
}
