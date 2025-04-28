{ pkgs, config, lib, username, ... }:

{
home.stateVersion = "24.05";
  home.packages = with pkgs; [
    # Add your packages here
  ];

}
