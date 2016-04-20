;; Typescript
(unless (package-installed-p 'typescript-mode)
  (package-install 'typescript-mode))
(unless (package-installed-p 'tss)
  (package-install 'tss))

;; (unless (package-installed-p 'flycheck-typescript-tslint)
;;   (package-install 'flycheck-typescript-tslint))


(require 'typescript)
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))

(require 'tss)
;; Key bindings
(tss-config-default)
(setq tss-popup-help-key "C-:")
(setq tss-jump-to-definition-key "C->")
(setq tss-implement-definition-key "C-c i")



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
