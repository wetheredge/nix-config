{
  config,
  lib,
  ...
}: let
  hostname = "knot.wetheredge.com";
  user = "git";
in {
  services.tangled-knot = rec {
    enable = true;
    server = {
      inherit hostname;
      owner = "did:plc:kbeqwhgvoa63f3mmbldlawqq";
      listenAddr = "127.0.0.1:5555";
    };
    # Push over tailscale only
    openFirewall = false;
    stateDir = "/var/lib/knot";
    repo.scanPath = "${stateDir}/repos";
    gitUser = user;
  };

  services.caddy.virtualHosts = {
    "${hostname}".extraConfig = "reverse_proxy http://${toString config.services.tangled-knot.server.listenAddr}";
  };

  preservation.preserveAt.data.users.${user} = let
    toRelative = lib.removePrefix config.users.users.${user}.home;
  in {
    directories = [(toRelative config.services.tangled-knot.repo.scanPath)];
    files = [(toRelative config.services.tangled-knot.server.dbPath)];
  };
}
