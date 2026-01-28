{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    disko = {
      url = "github:nix-community/disko/v1.13.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.follows = "agenix";
      inputs.crane.follows = "crane";
      inputs.flake-utils.follows = "flake-utils";
    };
    # Pull in latest changes to agenix module used by ragenix
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.home-manager.follows = "home-manager";
    };

    preservation.url = "github:nix-community/preservation";
    demolition = {
      url = "github:wetheredge/demolition";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.crane.follows = "crane";
      inputs.flake-utils.follows = "flake-utils";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    tangled = {
      url = "git+https://tangled.org/tangled.org/core";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.gomod2nix.follows = "gomod2nix";
    };

    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets.url = "git+https://github.com/wetheredge/nix-secrets.git?shallow=1";

    # not used directly; just to reduce the number of inputs
    crane.url = "github:ipetkov/crane";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = inputs @ {
    self,
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
        inherit (inputs) demolition;
      };
      nixos = base // {inherit (inputs) nixos-hardware;};
      home = base;
    };

    hosts = {
      eowyn = "x86_64-linux";
      shelob = "x86_64-linux";
    };

    eachSystem = f: lib.genAttrs (import systems) f;
    treefmtEval = eachSystem (system: inputs.treefmt.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix);
  in {
    formatter = eachSystem (system: treefmtEval.${system}.config.build.wrapper);

    checks = eachSystem (system: {
      formatting = treefmtEval.${system}.config.build.check self;
    });

    nixosConfigurations = builtins.listToAttrs (lib.mapAttrsToList (host: system: {
        name = host;
        value = lib.nixosSystem {
          inherit system;
          specialArgs = (args system).nixos;
          modules = [
            inputs.disko.nixosModules.disko
            inputs.ragenix.nixosModules.default
            inputs.secrets.nixosModules.default
            inputs.preservation.nixosModules.preservation
            inputs.niri.nixosModules.niri
            inputs.tangled.nixosModules.knot
            inputs.home-manager.nixosModules.home-manager

            ./modules/nixos

            ./overlays/lix.nix
            ./overlays/locales
            {
              nixpkgs.overlays = [
                inputs.niri.overlays.niri
                (_: _: {unstable = import inputs.nixpkgs-unstable {inherit system;};})
              ];
            }

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
