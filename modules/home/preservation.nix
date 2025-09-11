{lib, ...}:
with lib; {
  options.preservation.preserveAt = genAttrs ["data" "state" "cache"] (_: {
    commonMountOptions = mkOption {
      type = types.listOf types.attrs;
      default = [];
    };
    directories = mkOption {
      type = types.listOf types.anything;
      default = [];
    };
    files = mkOption {
      type = types.listOf types.anything;
      default = [];
    };
  });
}
