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

        nrs = "sudo nixos-rebuild switch --flake /home/tsimon/dotfiles/nix";
      };
      bashrcExtra = ''
        export PATH="$PATH:$HOME/bin:$HOME/go/bin:$HOME/.npm-packages/bin:$HOME/.npm-packages-lib/node_modules/@mermaid-js/mermaid-cli/src:$HOME/.local/bin"
        export NODE_PATH="$HOME/.npm-packages/lib/node_modules"
      '';
    };
  };

}
