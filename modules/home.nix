{ pkgs, lib, username, ... }:

{
  programs.fish.enable = true;
  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.zoxide.enable = true;

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";

    # `programs.git` will generate the config file: ~/.config/git/config
      # to make git use this config file, `~/.gitconfig` should not exist!
      #
      #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
      activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
        rm -f ~/.gitconfig
      '';

    packages = with pkgs; [
      # C++ dev tools
      cmake
      gettext
      libtool
      automake
      autoconf
      texinfo
      # Add your packages here
      starship # Minimal, blazing-fast, and infinitely customizable prompt
      docker
      colima
    ];

    sessionPath = [
      "$home/"
    ];
  };

  programs.starship = {
    enable = true;

    settings = {
      character = {
        success_symbol = "[➜](bold green)";
      };
    };
  };

  programs.git = {
    enable = true;

    userName = "Eduardo Eidelwein Berlitz";
    userEmail = "1980796+eberlitz@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
    };

    includes = [
          {
            # use diffrent email & name for work
            path = "~/projects/everest/.gitconfig";
            condition = "gitdir:~/projects/everest/";
          }
        ];

  };

  programs.home-manager.enable = true;
}
