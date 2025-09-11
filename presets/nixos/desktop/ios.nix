{pkgs, ...}: {
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  environment.systemPackages = with pkgs; [
    libimobiledevice
    (python3.withPackages (python-pkgs: [
      python-pkgs.iosbackup
    ]))
  ];

  preservation.preserveAt.state.directories = ["/var/lib/lockdown"];
}
