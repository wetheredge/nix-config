{config, ...}: let
  cfg = config.services.linkding;
in {
  services.linkding = {
    enable = true;
    rev = "sha256:6697a042724d347ef3bce1d27acdfb9950c1422c39f90592d012b9e37e58d243"; # 1.44.2-alpine
    port = 3003;
    environmentFile = config.age.secrets.linkding-env.path;
  };

  services.caddy.virtualHosts = {
    "links.wetheredge.com" = {
      extraConfig = "reverse_proxy http://localhost:${toString cfg.port}";
      # Bind locally + tailscale
      listenAddresses = ["127.0.0.1" "::1" "100.104.193.124"];
    };
  };

  preservation.preserveAt.data.directories = [
    cfg.stateDirectory
  ];
}
