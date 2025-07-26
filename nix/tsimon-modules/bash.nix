{
  pkgs,
  config,
  ...
}: {

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historySize = 1000;
      historyFileSize = 2000;
      historyIgnore = [
        "ls"
        "cd"
        "pwd"
      ];
      initExtra = ''
        # swap capslock and control
        # setxkbmap -option ctrl:swapcaps
      '';
      shellAliases = {
        ls = "ls --color=auto";
        grep = "grep";
        fgrep = "frep --color=auto";
        egrep = "egrep --color=auto";

        ll = "ls -lah";
        la = "ls -Ah";
        l = "ls -CF";

        cal = "ncal -3";

        cd = "z";
        cdi = "zi";

        nrs = "sudo nixos-rebuild switch";
      };
      bashrcExtra = ''
        export PATH="$PATH:$HOME/bin:$HOME/go/bin"
      '';
    };
  };

}
