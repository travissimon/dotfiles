(unless (package-installed-p 'js2-mode)
  (package-install 'js2-mode))
;; (unless (package-installed-p 'tern)
;;  (package-install 'tern))
(unless (package-installed-p 'tern-auto-complete)
  (package-install 'tern-auto-complete))

(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-to-list 'interpreter-mode-alist '("node" . js2-mode))


;; Support for JSX is available via the derived mode `js2-jsx-mode'.  If you
;; also want JSX support, use that mode instead:

;;  (add-to-list 'auto-mode-alist '("\\.jsx?\\'" . js2-jsx-mode))
;;  (add-to-list 'interpreter-mode-alist '("node" . js2-jsx-mode))

;; tern
(add-hook 'js-mode-hook (lambda () (tern-mode t)))

;; subword
(add-hook 'js-mode-hook 'subword-mode)

;; (eval-after-load 'tern
;;   '(progn
;;      (require 'tern-auto-complete)
;;      (tern-ac-setup)))
;;(setq tern-ac-on-dot t)
