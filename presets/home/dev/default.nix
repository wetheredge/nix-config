{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./vcs.nix
  ];

  home.sessionVariables = {
    ASTRO_TELEMETRY_DISABLED = 1;
  };

  home.packages = with pkgs; [
    hyperfine # benchmarking
    lldb # debugger
    scc # count lines of code

    # Rust
    cargo-expand
    cargo-features-manager
  ];

  programs.helix = {
    # language servers
    extraPackages = with pkgs; [
      marksman # markdown
    ];

    languages = {
      language-server = {
        deno-lsp = {
          command = "deno";
          args = ["lsp"];
          config.deno.enable = true;
        };
      };

      language = let
        tsLike = {
          roots = ["deno.json" "deno.jsonc" "package.json"];
          language-servers = ["deno-lsp" "typescript-language-server"];
        };
      in
        lib.mapAttrsToList (name: attrs: {inherit name;} // attrs) {
          javascript = tsLike;
          typescript = tsLike;
        };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      disable_stdin = true;
      strict_env = true;
    };
    stdlib = ''
      # <https://github.com/direnv/direnv/wiki/Customizing-cache-location#human-readable-directories>
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
        local hash path
        echo "''${direnv_layout_dirs[$PWD]:=$(
          hash="$(sha1sum - <<< "$PWD" | head -c40)"
          path="''${PWD//[^a-zA-Z0-9]/-}"
          echo "''${XDG_CACHE_HOME:-"$HOME/.cache"}/direnv/layouts/$hash$path"
        )}"
      }
    '';
  };

  services.podman.enable = true;

  # Git tag signing
  services.gpg-agent.enable = true;
  programs.gpg = {
    enable = true;
    settings = {
      pinentry-mode = "loopback";
      default-new-key-algo = "ed25519/cert";
      auto-key-retrieve = true;
      keyserver-options = "honor-keyserver-url";
    };
  };

  xdg.configFile."pnpm/rc".text = "update-notifier=false";

  programs.bat.syntaxes = {
    Gleam = {
      src = pkgs.fetchFromGitHub {
        owner = "digitalcora";
        repo = "sublime-text-gleam";
        rev = "e3ad6724cb26b7c39622636173833d1ebd83b156";
        hash = "sha256-fzTwVG0lxSBh7F3A7nHET9Makh+UrIaIXjF/sc9Z5A0=";
      };
      file = "package/Gleam.sublime-syntax";
    };
    LinkerScript = {
      src = pkgs.fetchFromGitHub {
        owner = "jbw3";
        repo = "SublimeTextLinkerSyntax";
        rev = "041d15667eca429afd4ff3df3b8f8617a66fc410";
        hash = "sha256-sygtTWNZJyiRtDdPA8etjDzN0CSrhGUPSAJ6QVqspls=";
      };
      file = "LinkerScript.sublime-syntax";
    };
    WebAssembly = {
      src = pkgs.fetchFromGitHub {
        owner = "bathos";
        repo = "wast-sublime-syntax";
        rev = "6eb7302b23db58052bdc308b046d2ae0bef5e25a";
        hash = "sha256-eprrkcPQhpZIaFQ85isYNFvANjIKQ/VDS/2pBoXrXrk=";
      };
      file = "wast.sublime-syntax";
    };
  };

  preservation.preserveAt = {
    data.directories = [
      "Projects"
      "Work"
      {
        directory = ".gnupg";
        mode = "0700";
      }
    ];
    state.directories = [
      ".local/share/direnv/allow"
    ];
    cache.directories = [
      ".cache/direnv"
      ".cache/dprint"
      ".cache/pnpm"
      ".cargo/git"
      ".cargo/registry"
    ];
  };
}
