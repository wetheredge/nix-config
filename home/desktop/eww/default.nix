{pkgs, ...}: {
  programs.eww = {
    enable = true;
    configDir = ./config;
  };

  systemd.user.services = let
    bin = "${pkgs.eww}/bin/eww";
    open = window: {
      Unit = {
        Description = "ElKowars Wacky Widgets (${window})";
        Requires = ["eww.service"];
        After = ["eww.service"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${bin} open --no-daemonize '${window}'";
        ExecStop = "${bin} close --no-daemonize '${window}'";
        RemainAfterExit = true;
      };
      Install = {
        WantedBy = ["niri.service"];
      };
    };
  in {
    eww = {
      Unit = {
        Description = "ElKowars Wacky Widgets";
        Documentation = "https://elkowar.github.io/eww";
        # FIXME: Shouldn't these be graphical-session.target?
        After = ["niri.service"];
        PartOf = ["niri.service"];
      };
      Service = {
        ExecStart = "${bin} daemon --no-daemonize";
        ExecStop = "${bin} kill";
        ExecReload = "${bin} reload";
      };
      Install = {
        WantedBy = ["niri.service"];
      };
    };
    eww-open-status = open "status";
    eww-open-workspaces = open "workspaces";
  };
}
