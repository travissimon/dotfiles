;; Typescript development

(add-hook 'typescript-ts-mode-hook (lambda ()
	(subword-mode +1)
	(setopt display-fill-column-indicator-column 100)
	(display-fill-column-indicator-mode)))


(with-eval-after-load 'typescript-mode (add-hook 'typescript-mode-hook #'lsp))

;; angular language server
(setq lsp-clients-angular-language-server-command
	'("node"
	:init (setq lsp-keymap-prefix "C-c l")	"./node_modules/@angular/language-server"
		"--ngProbeLocations"
		"node_modules/"
		"--tsProbeLocations"
		"node_modules/"
		"--stdio"))
