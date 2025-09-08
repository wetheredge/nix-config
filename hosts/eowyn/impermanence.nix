{
  vars,
  pkgs,
  ...
}: {
  boot.initrd.systemd.enable = true;

  # Based on <https://blog.decent.id/post/nixos-systemd-initrd/#impermanence-rollback>
  boot.initrd.systemd.services.rollback = {
    description = "Backup old root and start fresh";
    wantedBy = ["initrd.target"];
    after = ["cryptsetup.target"];
    before = ["sysroot.mount"];
    path = with pkgs; [
      btrfs-progs
      coreutils
      util-linuxMinimal
    ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /mnt
      mount -t btrfs /dev/mapper/crypted /mnt
      if [[ -e /mnt/root ]]; then
        mkdir -p /mnt/root-backups
        timestamp="$(date --date="@$(stat -c %Y /mnt/root)" "+%Y-%m-%d_%H:%M:%S")"
        mv /mnt/root "/mnt/root-backups/$timestamp"
      fi

      delete_subvolumes_recursively() {
        IFS=$'\n'
        for vol in $(btrfs subvolume list -o "$1" | cut -f9- -d' '); do
          delete_subvolume_recursively "/mnt/$vol"
        done
        btrfs subvolume delete "$1"
      }

      for vol in $(find /mnt/root-backups/ -maxdepth 1 -mtime +30); do
        delete_subvolumes_recursively "$vol"
      done

      btrfs subvolume create /mnt/root
      umount /mnt
    '';
  };

  preservation.enable = true;
  preservation.preserveAt."/state" = {
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/fprint"
      "/var/lib/lockdown"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      {
        file = "/etc/machine-id";
        inInitrd = true;
      }
    ];
    users.${vars.user} = {
      directories = [
        {
          directory = ".ssh";
          mode = "0700";
        }
        "Documents"
        "Pictures"
        "Projects"

        ".steam"
        ".local/share/Steam"
        ".local/share/Replicube"
      ];
      files = [
        ".cache/kickoff/menu.csv"
        ".config/rbw/config.json"
        {
          file = ".local/share/rbw/device_id";
          mode = "0600";
        }
      ];
    };
  };

  systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];

  users.mutableUsers = false;
}
