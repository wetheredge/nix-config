{
  config,
  lib,
  pkgs,
  demolition,
  ...
}: let
  demolitionCfg = config.settings.demolition;
in {
  options.settings.demolition = with lib; {
    enable = mkOption {
      type = types.bool;
      description = "Demolish old sysroots on boot";
      default = config.preservation.enable;
    };

    package = mkOption {
      type = types.package;
      description = "Package to use for demolition";
      inherit (demolition.packages.${pkgs.system}) default;
    };

    device = mkOption {
      type = types.str;
      description = "Path to the device containing the subvolumes";
    };
    mountDirectory = mkOption {
      type = types.str;
      description = "Name of the directory to mount the device into";
      default = "/mnt";
    };
    rootSubvolume = mkOption {
      type = types.str;
      description = "Name of the temporary subvolume used for /";
      default = "root";
    };
    backupDirectory = mkOption {
      type = types.str;
      description = "Name of the directory to keep old roots in";
      default = "root-backups";
    };
    backupFormat = mkOption {
      type = types.str;
      description = "chrono format string for root volume backups (escaped for systemd)";
      default = "%%Y%%m%%d_%%H%%M%%S";
    };
    keep.duration = mkOption {
      type = types.str;
      description = "Keep all backups within this duration";
      default = "2weeks";
    };
    keep.count = mkOption {
      type = types.str;
      description = "Keep the most recent N backups";
      default = "5";
    };
  };

  config = {
    # TODO: assert users.mutableUsers?

    boot.initrd.systemd.initrdBin = [
      demolitionCfg.package
    ];
    boot.initrd.systemd.services.demolition = lib.mkIf demolitionCfg.enable {
      description = "Demolish old sysroots";
      wantedBy = ["initrd.target"];
      after = ["initrd-root-device.target"];
      before = ["sysroot.mount"];
      unitConfig.DefaultDependencies = "no";

      path = [
        pkgs.btrfs-progs
      ];
      environment = {
        DEMOLITION_DEVICE = demolitionCfg.device;
        DEMOLITION_MOUNT_DIR = demolitionCfg.mountDirectory;
        DEMOLITION_ROOT_VOLUME = demolitionCfg.rootSubvolume;
        DEMOLITION_BACKUP_DIR = demolitionCfg.backupDirectory;
        DEMOLITION_BACKUP_FORMAT = demolitionCfg.backupFormat;
        DEMOLITION_KEEP_DURATION = demolitionCfg.keep.duration;
        DEMOLITION_KEEP_COUNT = demolitionCfg.keep.count;
        DEMOLITION_LOG = "info";
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${demolitionCfg.package}/bin/demolition";
      };
    };

    systemd.suppressedSystemUnits = lib.optional config.preservation.enable "systemd-machine-id-commit.service";

    preservation.preserveAt = let
      mkPreserveAt = key: {
        persistentStoragePath = lib.mkDefault "/preserve/${key}";
        users = lib.mapAttrs (_user: home:
          with home.preservation.preserveAt.${key}; {
            inherit commonMountOptions directories files;
            inherit (home.home) username;
            home = home.home.homeDirectory;
          })
        config.home-manager.users;
      };
    in {
      data = mkPreserveAt "data";
      state = mkPreserveAt "state";
      cache =
        mkPreserveAt "cache"
        // {
          directories = [
            "/var/log"
            "/var/lib/nixos"
            "/var/lib/systemd"
          ];
          files = [
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
          ];
        };
    };
  };
}
