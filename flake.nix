{
  description = "nix-darwin configs for my machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      username = "eberlitz";
      hostname = "eberlitz-MacBook-Pro";
      system = "aarch64-darwin";
      specialArgs = {
        inherit inputs username hostname;
      };
      mainConfigurationModule =
        { pkgs, config, lib, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs ; [
            vim
            git

            # JSON processor
            jq
            # command line fuzzy finder
            fzf

            fish

            # Core Utils / Replacements
            ripgrep # Extremely fast recursive line searching (like grep)
            fd # Simple, fast, and user-friendly alternative to find
            bat # A cat clone with syntax highlighting and Git integration
            eza # A modern replacement for ls (previously exa)
            zoxide # A smarter cd command that learns your habits
            dust # More intuitive version of du (package name: du-dust)
            duf # Disk Usage/Free Utility

            # Development / Git
            hyperfine # Command-line benchmarking tool
            tokei # Displays statistics about your code

            # System / Monitoring
            bottom # Graphical cross-platform process/system monitor

            # Shell / Terminal Enhancement

            helix # rust powered text editor
            uv # Python module manager

            just # Command-line utility for running shell commands

            nixd # LSP for nix files
          ];

          environment.shells = [
              pkgs.fish
            ];

          environment.variables.EDITOR = "hx";

          # Necessary for using flakes on this system.
          nix.enable = false;

          # Enable alternative shell support in nix-darwin.
          programs.fish = {
            enable = true;
            shellInit = '';
              set fish_greeting
            '';
          };

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

          # allows touch id authentication in terminal
          security.pam.services.sudo_local.touchIdAuth = true;

          # adds darwin-rebuild to path
          programs.zsh.enable = true;

          system.defaults = {
            dock.autohide = true;
            dock.mru-spaces = false;
            finder.AppleShowAllExtensions = true;
            finder.FXPreferredViewStyle = "clmv";
            loginwindow.LoginwindowText = "eberlitz";
            screencapture.location = "~/Pictures/screenshots";
            screensaver.askForPasswordDelay = 10;
          };

          # Fonts configuration
          fonts.packages = with pkgs; [
            nerd-fonts.fira-code
          ];

          networking.hostName = hostname;
          networking.computerName = hostname;
          system.defaults.smb.NetBIOSName = hostname;

          # Define the primary user for Home Manager and system settings
            users.users.${username} = {
              home = "/Users/${username}";
              # Add other user settings if needed, like groups
            };

        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#eberlitz-MacBook-Pro
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {

        inherit system;
        modules = [
          ./modules/system.nix
          mainConfigurationModule

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${username} = import ./modules/home.nix;
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
    };
}
