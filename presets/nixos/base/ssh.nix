{
  config,
  lib,
  ...
}: let
  sshHostKey = "/etc/ssh/ssh_host_ed25519_key";
in {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
    # Use pregenerated keys only
    hostKeys = [];
  };
  # TODO: set programs.ssh.knownHosts from GitHub api?

  programs.mosh = {
    enable = true;
    # Only over tailnet
    openFirewall = false;
  };

  age.identityPaths = let
    prefix = lib.optionalString config.preservation.enable config.preservation.preserveAt.state.persistentStoragePath;
  in [(prefix + sshHostKey)];

  preservation.preserveAt.state.files = [
    "${sshHostKey}.pub"
    {
      file = sshHostKey;
      mode = "0600";
    }
  ];
}
