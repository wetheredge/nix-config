{
  config,
  pkgs,
  ...
}: let
  hostname = "pds.wetheredge.com";
  user = "pds";
  group = "pds";

  cfg = config.services.bluesky-pds;
in {
  services.bluesky-pds = {
    enable = true;
    package = pkgs.unstable.bluesky-pds;
    pdsadmin.enable = true;
    settings = {
      PDS_HOSTNAME = hostname;
      PDS_PORT = 3000;
    };
    environmentFiles = [config.age.secrets.pds-env.path];
  };

  age.secrets.pds-env = {
    inherit group;
    owner = user;
  };

  services.caddy.virtualHosts = {
    "${hostname}" = {
      extraConfig = "reverse_proxy http://127.0.0.1:${toString cfg.settings.PDS_PORT}";
    };
  };

  preservation.preserveAt.data.directories = [
    {
      directory = "/var/lib/pds";
      inherit user group;
    }
  ];
}
