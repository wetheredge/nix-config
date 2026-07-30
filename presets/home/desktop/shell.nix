{
  programs.fish.functions = {
    steal = {
      description = "Replace a nix store link with the file it points to and make it writable";
      argumentNames = ["link"];
      body = ''
        if test ! -L $link
          echo 'Not a symlink'
          return 1
        end

        cp --remove-destination (readlink -e $link) $link
        chmod +w $link
      '';
    };
  };

  programs.nix-your-shell = {
    enable = true;
    nix-output-monitor.enable = true;
  };
}
