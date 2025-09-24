_default:
    @just --list --unsorted --justfile '{{ justfile() }}'

switch:
    nixos-rebuild switch --flake .

switch-for host:
    nixos-rebuild switch --flake .#{{ host }} --target-host {{ host }} --use-remote-sudo

boot:
    nixos-rebuild boot --flake .

boot-for host:
    nixos-rebuild boot --flake .#{{ host }} --target-host {{ host }} --use-remote-sudo

dry-build host=`hostname`:
    nixos-rebuild dry-build --flake .#{{host}}

build host=`hostname`:
    nixos-rebuild build --flake .#{{host}}

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
