;; This config assumes helm is installed

;; projectile
(use-package projectile
  :ensure t)
(use-package helm-projectile
  :ensure t)
(projectile-global-mode)
(helm-projectile-on)



;; auto-complete
(use-package auto-complete
  :ensure t)
(use-package ac-helm
  :ensure t)

;; (use-package auto-complete-config
;;   :ensure t)

;; magit
(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))


;; flycheck
;; (add-hook 'after-init-hook #'global-flycheck-mode)
