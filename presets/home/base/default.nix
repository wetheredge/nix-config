{
  vars,
  pkgs,
  ...
}: {
  imports = [
    ./editor.nix
    ./shells.nix
  ];

  home = {
    language.base = "da_US.UTF-8@wren";
    username = vars.user;
    homeDirectory = "/home/${vars.user}";
    preferXdgDirectories = true;
  };

  home.packages = with pkgs; [
    age # encryption
    choose # better cut
    delta # pretty diffs
    doggo # DNS client
    duf # device/partition usage stats
    dust # file/directory size stats
    file # guess file types
    gping # graphical ping
    hexyl # hex viewer
    jless # TUI json browser/viewer
    miniserve # simple HTTP server
    ncdu # interactive disk usage analyzer
    ouch # Obvious Unified Compression Helper
    procs # process management
    pv # monitor pipe progress
    qrrs # QR codes
    sd # simple sed s///g
    xh # easy to use HTTP client
  ];

  # cat + syntax highlighting
  programs.bat = {
    enable = true;
    config.map-syntax = [
      "*.ino:C++"
      # "*.x:Linker Script"
      ".ignore:Git Ignore"
    ];
  };

  # TUI system monitor
  programs.bottom.enable = true;

  programs.eza = {
    enable = true;
    enableFishIntegration = false;
    extraOptions = [
      "--git"
    ];
  };
  programs.fish.shellAliases = {
    ls = "eza";
    ll = "eza --long";
    la = "eza --all";
    lla = "eza --long --all";
  };

  programs.fd.enable = true;

  programs.jq.enable = true;

  # interactive jq
  programs.jqp.enable = true;

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case"
    ];
  };

  preservation.preserveAt.data.directories = [
    {
      directory = ".ssh";
      mode = "0700";
    }
  ];
}
