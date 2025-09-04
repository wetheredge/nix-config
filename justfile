_default:
    @just --list --unsorted --justfile '{{justfile()}}'

switch:
    nixos-rebuild switch --flake .

dry-build:
    nixos-rebuild dry-build --flake .

diff:
    nixos-rebuild build --flake . && nvd diff /run/current-system result && rm result
