{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    disko = {
      url = "github:nix-community/disko/v1.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";

    treefmt.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs @ {
    nixpkgs,
    systems,
    ...
  }: let
    inherit (nixpkgs) lib;
    vars = import ./vars.nix;

    args = rec {
      base = {inherit vars;};
      nixos = base // {inherit (inputs) nixos-hardware;};
      home = base;
    };

    hosts = {
      eowyn = "x86_64-linux";
    };

    eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
    treefmtEval = eachSystem (pkgs: inputs.treefmt.lib.evalModule pkgs ./treefmt.nix);
  in {
    formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

    nixosConfigurations = builtins.listToAttrs (lib.mapAttrsToList (host: system: {
        name = host;
        value = lib.nixosSystem {
          inherit system;
          specialArgs = args.nixos;
          modules = [
            inputs.disko.nixosModules.disko
            inputs.preservation.nixosModules.preservation
            inputs.home-manager.nixosModules.home-manager

            ./modules/nixos

            ./overlays/locales

            ./presets/nixos/base.nix
            ./hosts/${host}

            {networking.hostName = host;}

            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = args.home;

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
