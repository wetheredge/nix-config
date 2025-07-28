{ pkgs, ... }: {
  console = {
    earlySetup = true;
    font = "ter-v28n";
    packages = [ pkgs.terminus_font ];
  };
}
