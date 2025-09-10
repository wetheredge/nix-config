{
  pkgs,
  vars,
  ...
}: let
  catppuccinMocha = {
    text = "#cdd6f4";
    base = "#1e1e2e";
  };

  greeter = builtins.toString [
    "${pkgs.cage}/bin/cage -s --"
    "${pkgs.greetd-mini-wl-greeter}/bin/greetd-mini-wl-greeter"
    "--hide-cursor"
    "--background-color=${catppuccinMocha.base}"
    "--entry-color=${catppuccinMocha.base}"
    "--text-color=${catppuccinMocha.text}"
    "--outline-width=0"
    "--border-width=0"
    "--user=${vars.user}"
    "--command=niri-session"
  ];
in {
  services.greetd = {
    enable = true;
    settings = {
      default_session.command = greeter;
    };
  };
}
