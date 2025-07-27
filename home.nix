{ config, pkgs, ... }: {
  home.username = "wren";
  home.homeDirectory = "/home/wren";
  home.preferXdgDirectories = true;

  home.packages = with pkgs; [
    bat
    ripgrep

    # language servers
    nixd

    # monitoring
    btop
  ];

  programs.git = {
    enable = true;
    userName = "Wren Etheredge";
    userEmail = "me@wetheredge.com";
  };

  programs.starship = {
    enable = true;
    settings = {
      git_metrics.disabled = false;
      nodejs.detect_files = [ "package.json" ".node-version" "!bunfig.toml" "!bun.lockb" ];
      status.disabled = false;
    };
  };

  home.shell.enableShellIntegration = true;
  programs.eza = {
    enable = true;
    git = true;
  };
  programs.fish = {
    enable = true;
    preferAbbrs = true;
    shellAbbrs = {
      c = "cd";
      l = "eza";
    };
    interactiveShellInit = ''
      set fish_greeting
    '';
  };
  programs.bash = {
    enable = true;
    initExtra = ''
      # Based on <https://wiki.nixos.org/wiki/Fish#Setting_fish_as_default_shell>
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]; then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  home.stateVersion = "25.05";
}
