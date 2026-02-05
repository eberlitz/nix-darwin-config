{ pkgs, config, lib, username, ... }:

{
  programs.fish.enable = true;
  programs.bash.enable = true;
  programs.zsh.enable = true;

  homebrew = {
    enable = true;
    brews = [
      
    ];
    casks = [
    ];
  };
}
