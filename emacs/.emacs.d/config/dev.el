;; This config assumes helm is installed

;; Install company, which is used by lsp-mode
(use-package company
  :ensure t)

(add-hook 'after-init-hook 'global-company-mode)

(setq company-idle-delay
      (lambda () (if (company-in-string-or-comment) nil 0.2)))

(setq company-icon-margin 4)

;;;; A few more useful configurations...
(use-package emacs
 :init
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete))



;; Install LSP
(setq lsp-keymap-prefix "C-c l")

;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
;; See https://github.com/minad/corfu/wiki for more corfu configuration with lsp mode
(use-package lsp-mode
	:hook (
		   (typescript-mode . lsp))
	:commands lsp
	:custom
	(lsp-keymap-prefix "C-c l"))

;; optionally
;; if you are helm user
(use-package helm-lsp
  :after helm
  :commands helm-lsp-workspace-symbol)


(setq lsp-keymap-prefix "C-c l")



;; projectile
(use-package projectile
  :ensure t)
(use-package helm-projectile
  :ensure t)

(projectile-global-mode)
(setq projectile-completion-system 'helm)
(helm-projectile-on)
(setq projectile-enable-caching t)


;; add to ignored files
(add-to-list 'projectile-globally-ignored-directories "node_modules")

(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(global-set-key (kbd "C-c C-d") 'helm-browse-project)
(global-set-key (kbd "C-c p h") 'helm-projectile)
(global-set-key (kbd "C-x b") 'helm-mini)




;; magit
(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

;; editor config
(use-package editorconfig
  :ensure t
  :config (editorconfig-mode 1))


;; DAP mode
;;(use-package dap
;;  :ensure t
;;  :config (editorconfig-mode 1))

;;(dap-mode 1)

;; The modes below are optional
;;(dap-ui-mode 1)
;; enables mouse hover support
;;(dap-tooltip-mode 1)
;; use tooltips for mouse hover
;; if it is not enabled `dap-mode' will use the minibuffer.
;;(tooltip-mode 1)
;; displays floating panel with debug buttons
;; requies emacs 26+
;;(dap-ui-controls-mode 1)




;; flycheck
;; (add-hook 'after-init-hook #'global-flycheck-mode)





;; Corfu works, but is quiet slow :-/
;;
;; Corfu for syntax completion
;; see https://github.com/minad/corfu
;;(use-package corfu
  ;; Optional customizations
;;  :custom
;;  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
;;  (corfu-auto t)                 ;; Enable auto completion
;;  ;; (corfu-separator ?\s)          ;; Orderless field separator
;;  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
;;  (corfu-quit-no-match t)           ;; Quit early, I thihnk
;;  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
;;  ;; (corfu-preselect-first nil)    ;; Disable candidate preselection
;;  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
;;  ;; (corfu-echo-documentation nil) ;; Disable documentation in the echo area
;;  ;; (corfu-scroll-margin 5)        ;; Use scroll margin
;;
;;  ;; Enable Corfu only for certain modes.
;;  ;; :hook ((prog-mode . corfu-mode)
;;  ;;        (shell-mode . corfu-mode)
;;  ;;        (eshell-mode . corfu-mode))
;;
;;  ;; Recommended: Enable Corfu globally.
;;  ;; This is recommended since Dabbrev can be used globally (M-/).
;;  ;; See also `corfu-excluded-modes'.
;;
;;  :config
;;  ;; Free the RET key for less intrusive behavior.
;;  ;; Option 1: Unbind RET completely
;;  ;; (keymap-unset corfu-map "RET")
;;  ;; Option 2: Use RET only in shell modes
;;  (keymap-set corfu-map "RET" `( menu-item "" nil :filter
;;                                 ,(lambda (&optional _)
;;                                    (and (derived-mode-p 'eshell-mode 'comint-mode)
;;                                         #'corfu-send))))
;;
;;  :ensure t
;;  :init (global-corfu-mode))
;;
;;;; A few more useful configurations...
(use-package emacs
 :init
;;  ;; TAB cycle if there are only few candidates
;;  ;; (setq completion-cycle-threshold 3)
;;
;;  ;; Emacs 28: Hide commands in M-x which do not apply to the current mode.
;;  ;; Corfu commands are hidden, since they are not supposed to be used via M-x.
;;  (setq read-extended-command-predicate
;;        'command-completion-default-include-p)
;;
  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete))
;;  ;; Emacs 30 and newer: Disable Ispell completion function. As an alternative,
;;  ;; try `cape-dict'.
;;  (setq text-mode-ispell-word-completion nil)
;;
;;  ;; Emacs 28 and newer: Hide commands in M-x which do not apply to the current
;;  ;; mode.  Corfu commands are hidden, since they are not used via M-x. This
;;  ;; setting is useful beyond Corfu.
;;  (setq read-extended-command-predicate #'command-completion-default-include-p))



;; Github copilot
;; (use-package copilot
;;  :quelpa (copilot :fetcher github-ssh
;;                   :repo "zerolfx/copilot.el"
;;                   :branch "main"
;;                   :files ("dist" "*.el")))

;; (require 'copilot)
;; (add-hook 'prog-mode-hook 'copilot-mode)

;; (define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
;; (define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion)


;; specific languages
(load "/home/tsimon/.emacs.d/config/dev-html.el")
;;(load "/home/tsimon/.emacs.d/config/dev-js.el")
(load "/home/tsimon/.emacs.d/config/dev-typescript.el")
;; (load "/home/tsimon/.emacs.d/config/dev-pug.el")
;; (load "/home/tsimon/.emacs.d/config/dev-clojure.el")
;; (load "/home/tsimon/.emacs.d/config/dev-go.el")



;; for lsp mode performance
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))
(setq lsp-idle-delay 0.400)
(setq lsp-log-io nil)

(add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\.angular\\'")
(add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\decisions\\'")
(add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\deployment\\'")
(add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\diagrams\\'")
(add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\dist\\'")
(add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\files\\'")
(add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\file-uploads\\'")
(add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\.nx\\'")
(add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\tmp\\'")
