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
      home-manager,
      nixpkgs,
      nix-darwin,
      ...
    }:
    let
      hostname = "eberlitz-MacBook-Pro";
      username = "eberlitz";
      system = "aarch64-darwin";
      mainConfigurationModule =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
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
            nil # LSP for nix files
            starship # Minimal, blazing-fast, and infinitely customizable prompt

            direnv
          ];

          environment.shells = [
            pkgs.fish
          ];

          environment.variables.EDITOR = "hx";

          # Disabled because the Determinate Nix Installer manages the daemon;
          # enabling it here would conflict with it.
          nix.enable = false;

          # Enable alternative shell support in nix-darwin.
          programs.fish = {
            enable = true;
            shellInit = ''
              set fish_greeting
            '';
          };

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.primaryUser = username;
          users.users.${username} = {
            home = "/Users/${username}";
            name = username;
          };

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = system;

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
          # system.defaults.smb.NetBIOSName = hostname;

        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#eberlitz-MacBook-Pro
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit inputs hostname;
        };
        modules = [
          ./modules/system.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.extraSpecialArgs = {
              inherit inputs username;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./modules/home.nix;
          }
          mainConfigurationModule
        ];
      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
    };
}
