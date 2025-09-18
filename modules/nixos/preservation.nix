{
  config,
  lib,
  pkgs,
  ...
}: let
  rollbackCfg = config.settings.rollback;
in {
  options.settings.rollback = with lib; {
    enable = mkOption {
      type = types.bool;
      description = "Enable sysroot rollback on boot";
      default = config.preservation.enable;
    };

    device = mkOption {
      type = types.str;
      description = "Path to the device containing the subvolumes";
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
  };

  config = {
    # TODO: assert users.mutableUsers?

    # Based on <https://blog.decent.id/post/nixos-systemd-initrd/#impermanence-rollback>
    boot.initrd.systemd.services.rollback = lib.mkIf rollbackCfg.enable {
      description = "Rollback sysroot";
      wantedBy = ["initrd.target"];
      after = ["initrd-root-device.target"];
      before = ["sysroot.mount"];
      unitConfig.DefaultDependencies = "no";

      serviceConfig.Type = "oneshot";
      path = with pkgs; [
        btrfs-progs
        coreutils
        findutils
        util-linuxMinimal
      ];
      script = ''
        mkdir -p /mnt
        mount -t btrfs ${rollbackCfg.device} /mnt

        root='/mnt/${rollbackCfg.rootSubvolume}'
        backups='/mnt/${rollbackCfg.backupDirectory}'

        if [[ -e "$root" ]]; then
          mkdir -p "$backups"
          timestamp="$(date --date="@$(stat -c %Y "$root")" "+%Y-%m-%d_%H:%M:%S")"
          mv "$root" "$backups/$timestamp"
        fi

        delete_subvolumes_recursively() {
          IFS=$'\n'
          for vol in $(btrfs subvolume list -o "$1" | cut -f9- -d' '); do
            delete_subvolume_recursively "/mnt/$vol"
          done
          btrfs subvolume delete "$1"
        }

        for vol in $(find "$backups/" -maxdepth 1 -mtime +30); do
          delete_subvolumes_recursively "$vol"
        done

        btrfs subvolume create "$root"
        umount /mnt
      '';
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
            "/var/lib/systemd/coredump"
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
