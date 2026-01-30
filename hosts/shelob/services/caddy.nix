{
  services.wren.caddy.enable = true;

  services.caddy.virtualHosts = {
    "wetheredge.com".extraConfig = ''
      redir / https://github.com/wetheredge

      header /.well-known/openpgpkey/hu/* Content-Type application/octet-stream
      header /.well-known/openpgpkey/* Access-Control-Allow-Origin *

      root ${./www}
      file_server
    '';
    "www.wetheredge.com".extraConfig = "redir https://wetheredge.com{uri}";
  };
}
