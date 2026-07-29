set default-list

switch:
    nh os switch --ask

switch-for host:
    nh os switch --ask --target-host '{{ host }}'

boot:
    nh os boot --ask

boot-for host:
    nh os boot --target-host '{{ host }}'

build:
    nh os build --diff always

build-for host:
    nh os build --diff never --target-host '{{ host }}'

diff-for host:
    nh os build --diff always --target-host '{{ host }}'

build-image host *args='':
    nom build .#nixosConfigurations.{{ host }}.config.system.build.diskoImagesScript
    ./result {{ args }}

update: && build
    nix flake update

nixos-config path *args='':
    nix eval .#nixosConfigurations.$(hostname).config.{{ path }} {{ args }}

nixos-config-for host path *args='':
    nix eval .#nixosConfigurations.{{ host }}.config.{{ path }} {{ args }}

home-config path *args='':
    nix eval .#nixosConfigurations.$(hostname).config.home-manager.users.$(whoami).{{ path }} {{ args }}
