{
  config,
  pkgs,
  ...
}: {
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      hash = "sha256-p9AIi6MSWm0umUB83HPQoU8SyPkX5pMx989zAi8d/74=";
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.2.1"
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

  networking.firewall.interfaces.eth0 = {
    allowedTCPPorts = [80 443];
    allowedUDPPorts = [443];
  };
}
