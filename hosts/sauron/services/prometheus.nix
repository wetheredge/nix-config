{config, ...}: let
  cfg = config.services.prometheus;
in {
  services.prometheus = {
    enable = true;
    port = 3000;

    stateDir = "prometheus";

    globalConfig = {
      scrape_interval = "15s";
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {targets = ["sauron:${toString cfg.exporters.node.port}"];}
        ];
      }
      {
        job_name = "caddy";
        static_configs = [
          {targets = ["sauron:2019"];}
        ];
      }
    ];
  };

  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "systemd"
    ];
  };

  preservation.preserveAt.data.directories = [
    {
      directory = "/var/lib/${cfg.stateDir}";
      user = "prometheus";
      group = "prometheus";
    }
  ];
}
