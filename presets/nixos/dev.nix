{
  config,
  lib,
  pkgs,
  vars,
  ...
}: let
  probe-rs-udev-rules = pkgs.stdenv.mkDerivation {
    pname = "probe-rs-udev-rules";
    version = "2025-12-19";

    src = pkgs.fetchFromGitHub {
      owner = "probe-rs";
      repo = "webpage";
      rev = "7f669bcb78671a156957624acebfe4154ea1c5e8";
      hash = "sha256-Sb4bsCFLAB1lQ9a7QiX/qYDgoe9grrOk627BvYrHxOI=";
    };

    nativeBuildInputs = [pkgs.udevCheckHook];

    doInstallCheck = true;

    dontConfigure = true;
    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      mkdir -p $out/lib/udev/rules.d
      cp public/files/69-probe-rs.rules $out/lib/udev/rules.d/
    '';

    meta = {
      description = "udev rules for probe-rs";
      license = lib.licenses.gpl2;
      platforms = lib.platforms.linux;
      homepage = "https://probe.rs";
    };
  };
in {
  services.udev.packages = [
    probe-rs-udev-rules
  ];

  users.groups.plugdev.members = [vars.user];

  # symlink into place from home-manager to avoid creating ~/.config/git owned by root:root
  age.secrets.git-credentials = {
    owner = vars.user;
    inherit (config.users.users.${vars.user}) group;
  };
}
