_: {
  services.keyd = {
    enable = true;

    keyboards = {
      default = {
        ids = ["*"];
        extraConfig = builtins.readFile ./keyd.conf;
      };
    };
  };
}
