{secrets, ...}: {
  age = {
    identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    secrets = {
      tailscale-auth-key.file = "${secrets}/tailscale-auth-key.age";
    };
  };
}
