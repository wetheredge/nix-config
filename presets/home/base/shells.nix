{
  config,
  lib,
  pkgs,
  ...
}: {
  home.shell.enableShellIntegration = true;

  programs.fish = {
    enable = true;
    preferAbbrs = true;
    shellAbbrs = {
      c = "cd";
      l = "ls";
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

  programs.starship = {
    enable = true;
    settings = {
      git_metrics.disabled = false;
      nodejs.detect_files = ["package.json" ".node-version" "!bunfig.toml" "!bun.lockb"];
      status.disabled = false;
    };
  };

  preservation.preserveAt.state.files = lib.optional (!config.programs.atuin.enable) ".local/share/fish/fish_history";
}
