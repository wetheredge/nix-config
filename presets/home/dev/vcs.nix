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
      commit.verbose = true;
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

      aliases = let
        execBashScript = script: ["util" "exec" "--" "bash" "-c" script ""];
      in {
        bump = execBashScript ''
          set -eo pipefail
          if [[ -n "$1" ]]; then
            jj bookmark move "$1" -t "$1+"
          else
            jj bookmark move -f "closest_bookmark(@)" -t "closest_bookmark(@)+"
          fi
        '';
        # <https://zerowidth.com/2025/jj-tips-and-tricks/#bookmarks-and-branches>
        tug = ["bookmark" "move" "--from" "closest_bookmark(@-)" "--to" "@-"];
      };

      revset-aliases = {
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
      };

      templates = {
        git_push_bookmark = ''"${vars.devUser}/push-" ++ change_id.short()'';
        # Include diff in commit description editor
        # <https://jj-vcs.github.io/jj/v0.34.0/config/#default-description>
        draft_commit_description = ''
          concat(
            coalesce(description, default_commit_description, "\n"),
            surround(
              "\nJJ: Changes to be committed:\n",
              "",
              indent("JJ:     ", diff.stat(72)),
            ),
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
      };

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
