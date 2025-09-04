_default:
    @just --list --unsorted --justfile '{{justfile()}}'

switch:
    nixos-rebuild switch --flake .

dry-build:
    nixos-rebuild dry-build --flake .
