(setq lsp-keymap-prefix "C-c l")

;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
;; See https://github.com/minad/corfu/wiki for more corfu configuration with lsp mode
(use-package lsp-mode
	:init
	((defun my/lsp-mode-setup-completion ()
	    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
			'(flex))) ;; Configure flex
		(setq lsp-keymap-prefix "C-c l"))
	:custom
	(lsp-completion-provider :none) ;; we use Corfu!
	:hook (
		   (lsp-completion-mode . my/lsp-mode-setup-completion)
		   (typescript-mode . lsp))
	:commands lsp)

;; optionally
;;(use-package lsp-ui :commands lsp-ui-mode)
;; if you are helm user
(use-package helm-lsp :commands helm-lsp-workspace-symbol)

;; optionally if you want to use debugger
;; (use-package dap-mode)
;; (use-package dap-typescript)


(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config (setq typescript-indent-level 4)
  :ensure t)

;; angular language server
(setq lsp-clients-angular-language-server-command
	'("node"
	:init (setq lsp-keymap-prefix "C-c l")	"/home/tsimon/.nvm/versions/node/v19.9.0/lib/node_modules/@angular/language-server"
		"--ngProbeLocations"
		"/home/tsimon/.nvm/versions/node/v19.9.0/lib/node_modules/"
		"--tsProbeLocations"
		"/home/tsimon/.nvm/versions/node/v19.9.0/lib/node_modules/"
		"--stdio"))

