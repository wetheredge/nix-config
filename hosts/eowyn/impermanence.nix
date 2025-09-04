{
  vars,
  lib,
  ...
}: {
  boot.initrd.postResumeCommands = lib.mkAfter ''
    mkdir -p /mnt
    mount -t btrfs /dev/mapper/crypted /mnt
    if [[ -e /mnt/root ]]; then
      mkdir -p /mnt/root-backups
      timestamp="$(date --date="@$(stat -c %Y /mnt/root)" "+%Y-%m-%-d_%H:%M:%S")"
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

  environment.persistence."/state" = {
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/lockdown"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.${vars.user} = {
      directories = [
        {
          directory = ".ssh";
          mode = "u=rw,g=,o=";
        }
        "Documents"
        "Pictures"
        "Projects"
      ];
      files = [
        ".cache/kickoff/menu.csv"
        {
          file = ".config/rbw/config.json";
          parentDirectory = {mode = "u=rw,g=r,o=";};
        }
        {
          file = ".local/share/rbw/device_id";
          parentDirectory = {mode = "u=rw,g=r,o=";};
        }
      ];
    };
  };

  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  users.mutableUsers = false;
}
