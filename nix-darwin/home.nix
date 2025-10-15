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

	home.activation = {
		linkApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
			${pkgs.coreutils}/bin/ln -sfn "$HOME/.nix-profile/Applications" "$HOME/Applications/Nix Apps"
		'';
	};

	home.stateVersion = "25.05";
}
