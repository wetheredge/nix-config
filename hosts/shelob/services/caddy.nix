{
  config,
  pkgs,
  ...
}: let
  cfg = config.services.caddy;
in {
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      hash = "sha256-dnhEjopeA0UiI+XVYHYpsjcEI6Y1Hacbi28hVKYQURg=";
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.2.2"
      ];
    };

    environmentFile = config.age.secrets.caddy-env-shelob.path;
    globalConfig = ''
      acme_dns cloudflare {env.CF_API_TOKEN}
    '';

    virtualHosts = {
      "wetheredge.com".extraConfig = ''
        redir / https://github.com/wetheredge

        header /.well-known/openpgpkey/hu/* Content-Type application/octet-stream
        header /.well-known/openpgpkey/* Access-Control-Allow-Origin *

        root ${./www}
        file_server
      '';
      "www.wetheredge.com".extraConfig = "redir https://wetheredge.com{uri}";
    };
  };

  sockets.defaultGroup = cfg.group;

  networking.firewall.interfaces.eth0 = {
    allowedTCPPorts = [80 443];
    allowedUDPPorts = [443];
  };

  preservation.preserveAt.state.users.${cfg.user}.directories = [
    ".local/share/caddy"
  ];
}
