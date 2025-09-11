{lib, ...}: {
  # See:
  # - https://github.com/NixOS/nixpkgs/pull/166429
  # - https://github.com/NixOS/nixpkgs/issues/164357
  # - https://github.com/NixOS/nixpkgs/issues/166076

  options.security.pam.services = with lib;
    mkOption {
      type = types.attrsOf (types.submodule {
        config.fprintAuth = mkDefault false;
      });
    };

  config.security.pam.services.sudo.fprintAuth = true;
}
