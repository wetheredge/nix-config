{pkgs, ...}: {
  imports = [
    ./eww
    ./kickoff.nix
    ./theme.nix
  ];

  home.packages = with pkgs; [
    brightnessctl
    swayimg
    wev
    wl-clipboard-rs
    xwayland-satellite

    inter
    maple-mono.truetype
    twitter-color-emoji
  ];

  xdg.configFile = {
    "niri/config.kdl".source = ./niri/config.kdl;
    "niri/colors/light.kdl".source = ./niri/light.kdl;
    "niri/colors/dark.kdl".source = ./niri/dark.kdl;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = ["Twitter Color Emoji"];
      monospace = ["Maple Mono"];
      sansSerif = ["InterVariable" "Inter"];
    };
  };
}
