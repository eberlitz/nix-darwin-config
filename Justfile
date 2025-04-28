
# List all the just commands
default:
    @just --list

# Update all the flake inputs
[group('nix')]
up:
    nix flake update --commit-lock-file
    darwin-rebuild switch --flake .

[group('nix')]
fmt:
    nix fmt
