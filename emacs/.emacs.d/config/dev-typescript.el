
;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
(setq lsp-keymap-prefix "C-c l")

(use-package lsp-mode
    :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
            (typescript-mode . lsp))
    :commands lsp
	:init (setq lsp-keymap-prefix "C-c l"))

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)
;; if you are helm user
(use-package helm-lsp :commands helm-lsp-workspace-symbol)

;; optionally if you want to use debugger
;; (use-package dap-mode)
;; (use-package dap-typescript)


(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config (setq typescript-indent-level 4))

;; sample config
;; (add-hook 'typescript-mode-hook
;; 		  (lambda ()
;; 			(tide-setup)
;; 			(flycheck-mode +1)
;; 			(setq flycheck-check-syntax-automatically '(save mode-enabled))
;; 			(eldoc-mode +1)
;; 			;; company is an optional dependency. You have to
;; 			;; install it separately via package-install
;; 			(company-mode-on)))

;; ;; aligns annotation to the right hand side
;; (setq company-tooltip-align-annotations t)


;; angular language server
(setq lsp-clients-angular-language-server-command
  '("node"
    "/usr/lib/node_modules/@angular/language-server"
    "--ngProbeLocations"
    "/usr/lib/node_modules"
    "--tsProbeLocations"
    "/usr/lib/node_modules"
    "--stdio"))
