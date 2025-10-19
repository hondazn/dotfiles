# flake.nix
{
	description = "Example nix-darwin system flake";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
		# masterブランチは破壊的変更が入りやすいため、安定したブランチの利用を推奨します
		# 例: nix-darwin.url = "github:lnl7/nix-darwin";
		nix-darwin.url = "github:nix-darwin/nix-darwin/master";
		nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
		home-manager.url = "github:nix-community/home-manager";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
		let
			# 共通の変数を定義
			username = "hondazn";
			hostname = "mac";
			system = "aarch64-darwin";

			# pkgsを一度だけインポート
			pkgs = import nixpkgs {
				inherit system;
				config.allowUnfree = true;
			};

			# システム設定を定義 (元のconfigurationを流用)
			darwinConfig = { ... }: {
				# Disable NixOS module support.
				nix.enable = false;

				# List packages installed in system profile.
				environment.systemPackages = with pkgs; [
					vim
					_1password-gui
				];

				# Necessary for using flakes on this system.
				nix.settings.experimental-features = "nix-command flakes";

				security.pam.services.sudo_local.touchIdAuth = true;

				# Enable alternative shell support in nix-darwin.
				programs.fish.enable = true;

				system.primaryUser = username;
				system.defaults.finder = {
					AppleShowAllExtensions = true;
					AppleShowAllFiles = true;
					CreateDesktop = false;
					FXEnableExtensionChangeWarning = false;
					ShowPathbar = true;
					ShowStatusBar = true;
				};

				system.defaults.dock = {
					autohide = true;
					magnification = true;
					tilesize = 50;
					largesize = 128;
					show-recents = false;
				};

				# Set Git commit hash for darwin-version.
				system.configurationRevision = self.rev or self.dirtyRev or null;

				# Used for backwards compatibility
				system.stateVersion = 6;

				homebrew = {
					enable = true;
					taps = [
						# "jackielii/tap"
						# "koekeishiya/formulae"
						"pakerwreah/calendr"
					];
					brews = [
						# "jackielii/tap/skhd-zig"
						# "koekeishiya/formulae/yabai"
					];
					casks = [
						"scroll-reverser"
						"karabiner-elements"
						"calendr"
						"firefox@nightly"
					];
				};
			};
		in
			{
			# --- 1. システム設定 (sudo darwin-rebuild用) ---
			darwinConfigurations."${hostname}" = nix-darwin.lib.darwinSystem {
				# system と pkgs を渡す
				inherit system pkgs;
				# Home Managerのモジュールはここから削除する
				modules = [ darwinConfig ];
			};

			# --- 2. ユーザー設定 (home-manager switch用) ---
			homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
				# pkgs を渡す
				inherit pkgs;

				# ./home.nix をモジュールとして読み込む
				modules = [ (import ./home.nix) ];

				# Home Managerがユーザー情報を解決するためにextraSpecialArgsを追加するとより堅牢になります
				extraSpecialArgs = { inherit username; };
			};
		};
}
