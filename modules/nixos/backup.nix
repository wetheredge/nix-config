{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.wren.backup;
  toml = pkgs.formats.toml {};
in {
  options.services.wren.backup = with lib; {
    enable = mkEnableOption "backup";

    rusticPackage = mkPackageOption pkgs "rustic" {};

    passwordFile = mkOption {
      type = types.str;
      description = "Path to a file containing the password used for all repositories";
    };

    envFile = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    cacheDir = mkOption {
      type = types.str;
      default = "/var/cache/backup";
    };

    settings = mkOption {
      inherit (toml) type;
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    services.wren.backup.settings = {
      repository = {
        repository = "opendal:b2";
        password-file = cfg.passwordFile;
        cache-dir = cfg.cacheDir;
      };

      backup = {
        exclude-if-present = ["CACHEDIR.TAG" ".rustic-skip"];
        globs = ["!node_modules" "!zig-cache" "!CMakeFiles"];
        host = let
          inherit (config.environment.machine-info) prettyHostname;
        in
          if prettyHostname == null
          then config.networking.hostName
          else prettyHostname;

        # hooks = TODO

        snapshots = [
          {
            sources = [
              config.preservation.preserveAt.data.persistentStoragePath
              config.preservation.preserveAt.state.persistentStoragePath
            ];
          }
        ];
      };

      forget = {
        forget = true;
        keep-last = 10;
        keep-within-daily = "2 weeks";
        keep-within-weekly = "2 months";
        keep-monthly = -1;
      };
    };

    environment = {
      etc."rustic/system.toml".source = toml.generate "system.toml" cfg.settings;

      systemPackages = [
        (pkgs.writeShellScriptBin "backup" ''
          set -a # auto export
          ${lib.optionalString (cfg.envFile != null) "source ${cfg.envFile}"}
          exec ${cfg.rusticPackage}/bin/rustic -P system "$@"
        '')
      ];
    };

    preservation.preserveAt.cache.directories = [
      cfg.cacheDir
    ];
  };
}
