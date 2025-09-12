{lib, ...}:
with lib; {
  options.settings.languageServers = mkOption {
    type = types.listOf types.package;
    description = "Language server packages to provide to the default editor";
    default = [];
  };
}
