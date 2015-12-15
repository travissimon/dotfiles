;; This config assumes helm is installed

;; projectile
(require 'projectile)
(require 'helm-projectile)
(setq projectile-global-mode t)
(projectile-mode)
(helm-projectile-on)

;; auto-complete
(unless (package-installed-p 'auto-complete)
  (package-install 'auto-complete))
(unless (package-installed-p 'ac-helm)
  (package-install 'ac-helm))


;; magit
(unless (package-installed-p 'magit)
  (package-install 'magit))

(global-set-key (kbd "C-x g") 'magit-status)

;; flycheck
;; (add-hook 'after-init-hook #'global-flycheck-mode)
