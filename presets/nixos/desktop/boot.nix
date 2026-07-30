{pkgs, ...}: {
  boot = {
    loader.timeout = 0;

    plymouth = {
      enable = true;
      theme = "nixos-bgrt";
      themePackages = [pkgs.nixos-bgrt-plymouth];
    };

    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];
  };
}
