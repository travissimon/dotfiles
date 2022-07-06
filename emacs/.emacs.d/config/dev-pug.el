(use-package pug-mode
  :ensure t)

;; pug-mode for HAML-like express templates

(add-to-list 'auto-mode-alist '("\\.blade\\'" . pug-mode))
