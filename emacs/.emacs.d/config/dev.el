;; This config assumes helm is installed

;; projectile
(use-package projectile
  :ensure t)
(use-package helm-projectile
  :ensure t)
(projectile-global-mode)
(helm-projectile-on)

;; magit
(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

;; editor config
(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

;; flycheck
;; (add-hook 'after-init-hook #'global-flycheck-mode)

;; Corgu for syntax completion
;; see https://github.com/minad/corfu
(use-package corfu
  ;; Optional customizations
  ;; :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-auto t)                 ;; Enable auto completion
  ;; (corfu-separator ?\s)          ;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect-first nil)    ;; Disable candidate preselection
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-echo-documentation nil) ;; Disable documentation in the echo area
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin

  ;; Enable Corfu only for certain modes.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Recommended: Enable Corfu globally.
  ;; This is recommended since Dabbrev can be used globally (M-/).
  ;; See also `corfu-excluded-modes'.
  :ensure t
  :init
  (global-corfu-mode))


;; Autom completion mode - maybe disable?
(setq corfu-auto t
      corfu-quit-no-match 'separator)

;; A few more useful configurations...
(use-package emacs
  :init
  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)

  ;; Emacs 28: Hide commands in M-x which do not apply to the current mode.
  ;; Corfu commands are hidden, since they are not supposed to be used via M-x.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete))


;; specific languages
(load "/home/tsimon/.emacs.d/config/dev-html.el")
(load "/home/tsimon/.emacs.d/config/dev-js.el")
(load "/home/tsimon/.emacs.d/config/dev-typescript.el")
(load "/home/tsimon/.emacs.d/config/dev-pug.el")
;; (load "/home/tsimon/.emacs.d/config/dev-clojure.el")
;; (load "/home/tsimon/.emacs.d/config/dev-go.el")
