{pkgs, ...}: {
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = ["Twitter Color Emoji"];
      monospace = ["Maple Mono"];
      sansSerif = ["InterVariable" "Inter"];
    };
  };

  home.packages = with pkgs; [
    inter
    maple-mono.truetype
    twitter-color-emoji
  ];
}
