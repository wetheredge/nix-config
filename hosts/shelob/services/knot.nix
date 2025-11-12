{
  config,
  lib,
  ...
}: let
  cfg = config.services.tangled-knot;
in {
  services.tangled-knot = rec {
    enable = true;
    server = {
      hostname = "knot.wetheredge.com";
      owner = "did:plc:kbeqwhgvoa63f3mmbldlawqq";
      listenAddr = "127.0.0.1:5555";
    };
    # Push over tailscale only
    openFirewall = false;
    stateDir = "/var/lib/knot";
    repo.scanPath = "${stateDir}/repos";
    gitUser = "git";
  };

  services.caddy.virtualHosts = {
    "${cfg.server.hostname}".extraConfig = "reverse_proxy http://${toString cfg.server.listenAddr}";
  };

  preservation.preserveAt.data.users.${cfg.gitUser} = let
    toRelative = lib.removePrefix config.users.users.${cfg.gitUser}.home;
  in {
    directories = [(toRelative config.services.tangled-knot.repo.scanPath)];
    files = [(toRelative config.services.tangled-knot.server.dbPath)];
  };
}
