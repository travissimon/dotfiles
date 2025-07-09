
(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config (setq typescript-indent-level 4)
  :ensure t)

(add-hook 'typescript-mode-hook 'subword-mode)

;; angular language server
(setq lsp-clients-angular-language-server-command
	'("node"
	:init (setq lsp-keymap-prefix "C-c l")	"/home/tsimon/.nvm/versions/node/v22.2.0/lib/node_modules/@angular/language-server"
		"--ngProbeLocations"
		"node_modules/"
		"--tsProbeLocations"
		"node_modules/"
		"--stdio"))




;; DAP configuration

;;(use-package dap-chrome
;;  :ensure t)
;;(use-package dap-typescript
;;  :ensure t)
