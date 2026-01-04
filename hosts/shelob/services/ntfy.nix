{config, ...}: let
  cfg = config.services.ntfy-sh;
  host = "ntfy.wetheredge.com";
  stateDir = "/var/lib/private/ntfy-sh";
in {
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://${host}";
      listen-unix = "/run/ntfy-sh/ntfy.sock";
      listen-unix-mode = 666;
      behind-proxy = true;

      enable-signup = false;
      enable-login = false;
      web-root = "disable";
      attachment-cache-dir = "";

      # iOS notification proxy
      upstream-base-url = "https://ntfy.sh";

      cache-file = "${stateDir}/messages.db";

      auth-file = "${stateDir}/user.db";
      auth-default-access = "deny-all";
      auth-access = [];
    };
    environmentFile = config.age.secrets.ntfy-env.path;
  };

  systemd.services.ntfy-sh = {
    before = ["ntfy-boot.service"];
    # Ensure /run/ntfy-sh exists before the service starts
    serviceConfig.RuntimeDirectory = "ntfy-sh";
  };

  age.secrets.ntfy-env = {
    owner = cfg.user;
    inherit (cfg) group;
  };

  services.caddy.virtualHosts = {
    ${host}.extraConfig = ''
      redir / https://ntfy.sh
      reverse_proxy unix/${cfg.settings.listen-unix}
    '';
  };

  preservation.preserveAt.state.directories = [
    {
      directory = stateDir;
      inherit (cfg) user group;
    }
  ];
}
