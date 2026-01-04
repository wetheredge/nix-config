{lib, ...}: {
  options.wren.private = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = {};
    description = "Attrset of non-public things stored in the secrets repo that don't need to be hidden from the store.";
  };
}
