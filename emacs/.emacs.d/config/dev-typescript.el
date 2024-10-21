(setq lsp-keymap-prefix "C-c l")

;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
;; See https://github.com/minad/corfu/wiki for more corfu configuration with lsp mode
(use-package lsp-mode
	:hook (
		   (typescript-mode . lsp))
	:commands lsp
	:custom
	(lsp-keymap-prefix "C-c l"))

;; optionally
;; if you are helm user
(use-package helm-lsp
  :after helm
  :commands helm-lsp-workspace-symbol)

;; optionally if you want to use debugger
;; (use-package dap-mode)
;;(use-package dap-typescript)


(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config (setq typescript-indent-level 4)
  :ensure t)

;; angular language server
(setq lsp-clients-angular-language-server-command
	'("node"
	:init (setq lsp-keymap-prefix "C-c l")	"/home/tsimon/.nvm/versions/node/v22.2.0/lib/node_modules/@angular/language-server"
		"--ngProbeLocations"
		"node_modules/"
		"--tsProbeLocations"
		"node_modules/"
		"--stdio"))

