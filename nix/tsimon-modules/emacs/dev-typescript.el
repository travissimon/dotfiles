;; Typescript development

(add-hook 'typescript-mode-hook 'subword-mode)

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
