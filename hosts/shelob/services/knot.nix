{
  config,
  lib,
  ...
}: let
  cfg = config.services.tangled.knot;
in {
  services.tangled.knot = rec {
    enable = true;
    server = {
      hostname = "knot.wetheredge.com";
      owner = "did:plc:kbeqwhgvoa63f3mmbldlawqq";
      listenAddr = "127.0.0.1:3001";
    };
    # Push over tailscale only
    openFirewall = false;
    stateDir = "/var/lib/knot";
    repo.scanPath = "${stateDir}/repos";
    gitUser = "git";
  };

  services.openssh = {
    enable = true;
    ports = [2222];
    settings.AllowUsers = [cfg.gitUser];
  };

  services.caddy.virtualHosts = {
    "${cfg.server.hostname}".extraConfig = "reverse_proxy http://${toString cfg.server.listenAddr}";
  };

  preservation.preserveAt.data.users.${cfg.gitUser} = let
    toRelative = lib.removePrefix config.users.users.${cfg.gitUser}.home;
  in {
    directories = [(toRelative cfg.repo.scanPath)];
    files = [(toRelative cfg.server.dbPath)];
  };
}
