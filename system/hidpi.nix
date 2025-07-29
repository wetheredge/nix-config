# Only needed for VMs -- on native hardware Linux uses a larger font by default since 6.8

{ pkgs, ... }: {
  console = {
    font = "ter-v28n";
    packages = [ pkgs.terminus_font ];
  };
}
