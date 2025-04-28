{
  description = "nix-darwin configs for my machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.vim
          pkgs.git

          # JSON processor
          pkgs.jq
          # command line fuzzy finder
          pkgs.fzf

          pkgs.fish

          # Core Utils / Replacements
          pkgs.ripgrep # Extremely fast recursive line searching (like grep)
          pkgs.fd # Simple, fast, and user-friendly alternative to find
          pkgs.bat # A cat clone with syntax highlighting and Git integration
          pkgs.eza # A modern replacement for ls (previously exa)
          pkgs.zoxide # A smarter cd command that learns your habits
          pkgs.dust # More intuitive version of du (package name: du-dust)
          pkgs.duf # Disk Usage/Free Utility

          # Development / Git
          pkgs.hyperfine # Command-line benchmarking tool
          pkgs.tokei # Displays statistics about your code

          # System / Monitoring
          pkgs.bottom # Graphical cross-platform process/system monitor

          # Shell / Terminal Enhancement
          pkgs.starship # Minimal, blazing-fast, and infinitely customizable prompt

          pkgs.helix
          pkgs.uv

          pkgs.nixd # LSP for nix files
        ];

        # Necessary for using flakes on this system.
      nix.enable = false;
      nix.settings.experimental-features = "nix-command flakes";


      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

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
        loginwindow.LoginwindowText = "nixcademy.com";
        screencapture.location = "~/Pictures/screenshots";
        screensaver.askForPasswordDelay = 10;
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#eberlitz-MacBook-Pro
    darwinConfigurations."eberlitz-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin"; # Good practice
      modules = [ configuration ];
    };
  };
}
