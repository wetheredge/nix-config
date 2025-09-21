_default:
    @just --list --unsorted --justfile '{{ justfile() }}'

switch:
    nixos-rebuild switch --flake .

boot:
    nixos-rebuild boot --flake .

dry-build:
    nixos-rebuild dry-build --flake .

diff:
    nixos-rebuild build --flake . && nvd diff /run/current-system result && rm result

update: && diff
    nix flake update

nixos-config path *args='':
    nix eval .#nixosConfigurations.$(hostname).config.{{ path }} {{ args }}

nixos-config-for host path *args='':
    nix eval .#nixosConfigurations.{{ host }}.config.{{ path }} {{ args }}

home-config path *args='':
    nix eval .#nixosConfigurations.$(hostname).config.home-manager.users.$(whoami).{{ path }} {{ args }}
