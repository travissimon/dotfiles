;; Helm

(use-package helm
  :ensure t)
(use-package helm-flx
  :ensure t)
(use-package helm-fuzzier
  :ensure t)
(use-package helm-ls-git
  :ensure t)
(use-package helm-lsp
  :ensure t)
(use-package helm-projectile
  :ensure t)
(use-package helm-gitlab
  :ensure t)


(helm-mode 1)
;; (helm-fuzzier-mode 1)


;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
(global-unset-key (kbd "C-c h"))
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))

(setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
	  helm-reuse-last-window-split-state    t ; from https://github.com/thierryvolpiatto/emacs-config/blob/main/init-helm.el
      helm-buffers-fuzzy-matching           t ; fuzzy matching buffer names when non--nil
      helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
      helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
      helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
      helm-ag-insert-at-point               (quote word)
      helm-ff-search-library-in-sexp        t
      helm-move-to-line-cycle-in-source     t
      helm-ff-file-name-history-use-recentf t)

;; key bindings
(global-set-key (kbd "C-x f") 'helm-find-files)
(global-set-key (kbd "C-M-l") 'dired-jump)

(global-unset-key (kbd "M-x"))
(global-set-key (kbd "M-x") 'helm-M-x)

(global-unset-key (kbd "M-y"))
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
