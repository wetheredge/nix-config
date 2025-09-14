{config, ...}: {
  boot = {
    loader.efi.canTouchEfiVariables = true;
    kernelParams = [
      # Name interfaces by order instead of PCIe addresses (eth* vs enp*)
      "net.ifnames=0"
    ];
  };

  networking = {
    # Quad9
    nameservers = [
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"
    ];
    firewall = {
      trustedInterfaces = [config.services.tailscale.interfaceName];
      interfaces.eth0 = {
        allowedTCPPorts = [22];
      };
    };
  };

  services.tailscale.useRoutingFeatures = "server";
}
