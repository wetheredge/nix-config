{
  config,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    ../../presets/nixos/vps.nix

    ./disks.nix

    ./services
  ];

  preservation.enable = true;
  settings.demolition = {
    enable = true;
    device = "/dev/disk/by-partlabel/disk-main-root";
  };

  preservation.preserveAt.data.directories = let
    psql = config.systemd.services.postgresql.serviceConfig;
  in [
    {
      directory = "/var/lib/postgresql";
      user = psql.User;
      group = psql.Group;
      mode = "0750";
    }
  ];

  system.stateVersion = "25.05";
}
