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

    envFile = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    config = {
      repository = {
        repository = mkOption {
          type = types.str;
        };
        password-file = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        cache-dir = mkOption {
          type = types.str;
          default = "/var/cache/backup";
        };
      };

      forget = let
        times = ["minutely" "hourly" "daily" "weekly" "monthly" "quarterly" "half-yearly" "yearly"];
      in
        {
          prune = mkOption {
            type = types.bool;
            default = true;
          };
          keep-tags = mkOption {
            type = types.listOf types.str;
            default = [];
          };
        }
        // lib.listToAttrs (lib.map (name: {
          name = "keep-${name}";
          value = mkOption {
            type = types.nullOr types.int;
            default = null;
          };
        }) (lib.flatten ["last" times]))
        // lib.listToAttrs (lib.map (name: {
            name = "keep-within-${name}";
            value = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
          })
          times);
    };

    finalConfig = mkOption {
      inherit (toml) type;
      default = {};
    };

    timerConfig = mkOption {
      # FIXME: proper type?
      type = types.nullOr types.attrs;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    services.wren.backup.finalConfig = {
      inherit (lib.filterAttrsRecursive (_: v: v != null) cfg.config) repository forget;

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
    };

    environment = {
      etc."rustic/system.toml".source = toml.generate "system.toml" cfg.finalConfig;

      systemPackages = [
        (pkgs.writeShellScriptBin "backup" ''
          set -a # auto export
          ${lib.optionalString (cfg.envFile != null) "source ${cfg.envFile}"}
          args=("$@")
          if [[ "$args" == backup* ]]; then
            args+=("--tag=manual")
          fi
          exec ${cfg.rusticPackage}/bin/rustic -P system "''${args[@]}"
        '')
      ];
    };

    systemd = lib.mkIf (cfg.timerConfig != null) {
      services.backup = {
        description = "Run a system backup";
        after = ["network-online.target"];
        wants = ["network-online.target"];

        serviceConfig =
          {
            Type = "oneshot";
            ExecStart = "${cfg.rusticPackage}/bin/rustic -P system backup --tag scheduled";
          }
          // lib.optionalAttrs (cfg.envFile != null) {
            EnvironmentFile = cfg.envFile;
          };
      };

      timers.backup = {
        wantedBy = ["timers.target"];
        inherit (cfg) timerConfig;
      };
    };

    preservation.preserveAt.cache.directories = [
      cfg.config.repository.cache-dir
    ];
  };
}
