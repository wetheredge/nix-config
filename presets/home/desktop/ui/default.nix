{pkgs, ...}: {
  imports = [
    ./eww
    ./kickoff.nix
    ./theme.nix
    ./mako.nix
  ];

  home.packages = with pkgs; [
    brightnessctl
    libnotify
    swayimg
    wev
    wl-clipboard-rs
    xwayland-satellite

    inter
    maple-mono.truetype
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
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
      sansSerif = ["InterVariable" "Inter" "Noto Sans" "Noto Sans CJK SC"];
      serif = ["Noto Serif" "Noto Serif CJK SC"];
    };
  };
}
