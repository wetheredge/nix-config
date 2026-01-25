{config, ...}: {
  services.prometheus = {
    enable = true;
    port = 3004;

    globalConfig = {
      scrape_interval = "15s";
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {targets = ["localhost:${toString config.services.prometheus.exporters.node.port}"];}
        ];
      }
      {
        job_name = "caddy";
        static_configs = [
          {targets = ["localhost:2019"];}
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
}
