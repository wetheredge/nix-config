{pkgs, ...}: {
  home.packages = with pkgs; [
    golden-cheetah
  ];

  preservation.preserveAt.state.directories = [
    ".goldencheetah"
    ".config/goldencheetah.org"
  ];
}
