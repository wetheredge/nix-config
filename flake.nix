{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    disko = {
      url = "github:nix-community/disko/v1.12.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.follows = "agenix";
    };
    # Pull in latest changes to agenix module used by ragenix
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.home-manager.follows = "home-manager";
    };

    preservation.url = "github:nix-community/preservation";

    niri.url = "github:sodiboo/niri-flake";

    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets.url = "git+ssh://git@github.com/wetheredge/nix-secrets.git?shallow=1";
  };

  outputs = inputs @ {
    nixpkgs,
    systems,
    ...
  }: let
    inherit (nixpkgs) lib;
    vars = import ./vars.nix;

    args = system: rec {
      base = {
        inherit vars;
        pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
      };
      nixos = base // {inherit (inputs) nixos-hardware;};
      home = base;
    };

    hosts = {
      eowyn = "x86_64-linux";
      shelob = "x86_64-linux";
    };

    eachSystem = f: lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
    treefmtEval = eachSystem (pkgs: inputs.treefmt.lib.evalModule pkgs ./treefmt.nix);
  in {
    formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

    nixosConfigurations = builtins.listToAttrs (lib.mapAttrsToList (host: system: {
        name = host;
        value = lib.nixosSystem {
          inherit system;
          specialArgs = (args system).nixos;
          modules = [
            inputs.disko.nixosModules.disko
            inputs.ragenix.nixosModules.default
            inputs.secrets.nixosModules.secrets
            inputs.preservation.nixosModules.preservation
            inputs.niri.nixosModules.niri
            inputs.home-manager.nixosModules.home-manager

            ./modules/nixos

            ./overlays/locales
            {nixpkgs.overlays = [inputs.niri.overlays.niri];}

            ./presets/nixos/base.nix
            ./hosts/${host}

            {networking.hostName = host;}

            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = (args system).home;

                sharedModules = [
                  ./modules/home
                ];

                users.${vars.user}.imports = [
                  ./presets/home/base
                  ./hosts/${host}/home.nix
                ];
              };
            }
          ];
        };
      })
      hosts);
  };
}
