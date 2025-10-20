{
  vars,
  pkgs-unstable,
  ...
}: {
  programs.git = {
    enable = true;
    userName = vars.name;
    userEmail = vars.email;

    # Also used by jujutsu
    ignores = ["*~"];

    aliases = {
      tree = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
    };

    extraConfig = {
      diff.renames = "copies";
      fetch.pruneTags = true;
      help.autoCorrect = "prompt";
      init.defaultBranch = "main";
      log.date = "human";
      merge.conflictStyle = "diff3";
      rebase.autoSquash = true;
      rebase.missingCommitsCheck = "error";
      stash.showPatch = true;
      status.showStash = true;
      tag.gpgSign = true;

      url = {
        # Always use ssh auth for personal GH repos
        "git@github.com:${vars.devUser}/".insteadOf = "https://github.com/${vars.devUser}/";
      };
    };
  };

  # programs.git.delta = {
  #   enable = true;
  # };

  programs.jujutsu = {
    enable = true;
    package = pkgs-unstable.jujutsu;
    settings = {
      user = {
        inherit (vars) name email;
      };

      ui = {
        default-command = "status";
        diff-editor = ":builtin";
        pager = "less -FRX";
      };

      # Enable colocated git repos by default
      git.colocate = true;

      templates.git_push_bookmark = ''"${vars.devUser}/push-" ++ change_id.short()'';

      revset-aliases = {
        "ahead()" = "remote_bookmarks()..bookmarks()";
        "behind()" = "bookmarks()..remote_bookmarks()";
      };
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = false;
    settings = {
      git_protocol = "ssh";
    };
    hosts."github.com" = {
      user = vars.devUser;
    };
  };
}
