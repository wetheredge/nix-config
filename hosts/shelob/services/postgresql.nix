{config, ...}: {
  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
    compression = "none";
    startAt = [];
  };

  systemd.services.postgresqlBackup = {
    before = ["backup.service"];
    wantedBy = ["backup.service"];
  };

  services.wren.backup.extraSources = [config.services.postgresqlBackup.location];

  preservation.preserveAt.data.directories = let
    service = config.systemd.services.postgresql.serviceConfig;
  in [
    {
      directory = "/var/lib/postgresql";
      user = service.User;
      group = service.Group;
      mode = "0750";
    }
  ];
}
