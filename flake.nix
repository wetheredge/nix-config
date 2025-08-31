{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    disko = {
      url = "github:nix-community/disko/v1.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, ... }: let
    inherit (nixpkgs) lib;
    vars = import ./vars.nix;
    args = { inherit vars; };
    hosts = {
      deagol = "x86_64-linux";
      eowyn = "x86_64-linux";
    };
  in {
    nixosConfigurations = builtins.listToAttrs (lib.mapAttrsToList (host: system: {
      name = host;
      value = lib.nixosSystem {
        inherit system;
        specialArgs = args;
        modules = [
          inputs.disko.nixosModules.disko
          inputs.impermanence.nixosModules.impermanence
          inputs.home-manager.nixosModules.home-manager

          ./system/base.nix
          ./hosts/${host}

          { networking.hostName = host; }

          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = args;
              users.${vars.user}.imports = [
                ./home/base
                ./hosts/${host}/home.nix
              ];
            };
          }
        ];
      };
    }) hosts);
  };
}
