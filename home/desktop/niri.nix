{ pkgs, ... }: {
  home.packages = with pkgs; [
    swayimg
  ];

  programs = {
    alacritty.enable = true;
  };
}
