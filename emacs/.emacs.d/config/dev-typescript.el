;; Typescript
;;(unless (package-installed-p 'typescript-mode)
;;  (package-install 'typescript-mode))
;; (unless (package-installed-p 'tss)
;;  (package-install 'tss))

;; (unless (package-installed-p 'flycheck-typescript-tslint)
;;   (package-install 'flycheck-typescript-tslint))

;; (require 'typescript)
;;(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))


;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
(setq lsp-keymap-prefix "C-c l")

(use-package lsp-mode
    :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
            (typescript-mode . lsp))
    :commands lsp)

;;(use-package company
;;  :after lsp-mode
;;  :hook (lsp-mode . company-mode)
;;  :bind (:map company-active-map
;;			  ("<tab>" . company-complete-selection))
;;  (:map lsp-mode-map
;;		("<tab>" . company-indent-or-complete-common))
;;  :custom
;;  (company-minimum-prefix-length 1)
;;  (company-idle-delay 0.0))

;;(require 'company-lsp)
;;(push 'company-lsp company-backend)

;; optionally
;;(use-package lsp-ui :commands lsp-ui-mode)
;; if you are helm user
;;(use-package helm-lsp :commands helm-lsp-workspace-symbol)
;; if you are ivy user

;; optionally if you want to use debugger
;; (use-package dap-mode)
;; (use-package dap-typescript)





;; (use-package lsp-mode
;;  :commands (lsp lsp-deferred)
;;  :init (setq lsp-keymap-prefix "C-c l"))

(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config (setq typescript-indent-level 4))

;;(require 'tss)
;; Key bindings
;;(tss-config-default)
;;(setq tss-popup-help-key "C-:")
;;(setq tss-jump-to-definition-key "C->")
;;(setq tss-implement-definition-key "C-c i")



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

;; ;; Tide can be used along with web-mode to edit tsx files
;; (require 'web-mode)
;; (add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
;; (add-hook 'web-mode-hook
;; 	(lambda ()
;; 			(when (string-equal "tsx" (file-name-extension buffer-file-name))
;; 			  (tide-setup)
;; 			  (flycheck-mode +1)
;; 			  (setq flycheck-check-syntax-automatically '(save mode-enabled))
;; 			  (eldoc-mode +1)
;; 			  (ac-mode-on))))
