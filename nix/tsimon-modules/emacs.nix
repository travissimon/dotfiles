{
  pkgs,
  config,
  ...
}: {

  services = {
    emacs.defaultEditor = true;
  };

  home = {
    file.".emacs.d/init.el" = {
      source = ./emacs/init.el;
    };

    file.".emacs.d/config/casual.el" = {
      source = ./emacs/casual.el;
    };
    file.".emacs.d/config/dev.el" = {
      source = ./emacs/dev.el;
    };
    file.".emacs.d/config/dev-closure.el" = {
      source = ./emacs/dev-closure.el;
    };
    file.".emacs.d/config/dev-go.el" = {
      source = ./emacs/dev-go.el;
    };
    file.".emacs.d/config/dev-html.el" = {
      source = ./emacs/dev-html.el;
    };
    file.".emacs.d/config/dev-js.el" = {
      source = ./emacs/dev-js.el;
    };
    file.".emacs.d/config/dev-pug.el" = {
      source = ./emacs/dev-pug.el;
    };
    file.".emacs.d/config/dev-typescript.el" = {
      source = ./emacs/dev-typescript.el;
    };
    file.".emacs.d/config/general.el" = {
      source = ./emacs/general.el;
    };
    file.".emacs.d/config/helm.el" = {
      source = ./emacs/helm.el;
    };
    file.".emacs.d/config/misc.el" = {
      source = ./emacs/misc.el;
    };
    file.".emacs.d/config/org.el" = {
      source = ./emacs/org.el;
    };
    file.".emacs.d/config/themes.el" = {
      source = ./emacs/themes.el;
    };
    file.".emacs.d/config/tsimon-shell-theme.el" = {
      source = ./emacs/tsimon-shell-theme.el;
    };
    file.".emacs.d/config/tsimon-theme.el" = {
      source = ./emacs/tsimon-theme.el;
    };
    
  };

  programs = {
    emacs = {
      enable = true;
      package = pkgs.emacs-gtk;
      extraPackages = epkgs: [
        epkgs.ac-html
        epkgs.all-the-icons
        epkgs.auctex
        epkgs.casual
        epkgs.casual-suite
        epkgs.company
        epkgs.scss-mode
        epkgs.dap-mode
        epkgs.editorconfig
        epkgs.exec-path-from-shell
        epkgs.golint
        epkgs.gotest
        epkgs.go-autocomplete
        epkgs.go-projectile
        epkgs.go-rename
        epkgs.helm
        epkgs.helm-flx
        epkgs.helm-fuzzier
        epkgs.helm-gitlab
        epkgs.helm-lsp
        epkgs.helm-projectile
        epkgs.htmlize
        epkgs.js2-mode
        epkgs.less-css-mode
        epkgs.lsp-mode
        epkgs.magit
        epkgs.nix-mode
        epkgs.ng2-mode
        epkgs.no-littering
        epkgs.org
        epkgs.org-bullets
        epkgs.pretty-sha-path
        epkgs.projectile
        epkgs.treesit-grammars.with-all-grammars
        epkgs.typescript-mode
        epkgs.undo-tree
        epkgs.wakatime-mode
        epkgs.web-beautify
      ];
      extraConfig = ''
      '';
    };
  };

}
