;; Helm

(unless (package-installed-p 'helm)
  (package-install 'helm))
(unless (package-installed-p 'helm-core)
  (package-install 'helm-core))
(unless (package-installed-p 'helm-css-scss)
  (package-install 'helm-css-scss))
(unless (package-installed-p 'helm-flymake)
  (package-install 'helm-flymake))
(unless (package-installed-p 'helm-projectile)
  (package-install 'helm-projectile))
(unless (package-installed-p 'helm-themes)
  (package-install 'helm-themes))

(require 'helm-config)
(require 'helm-command)
(require 'helm-elisp)
(require 'helm-misc)
(require 'helm-css-scss)


;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
(helm-mode 1)

(global-unset-key (kbd "C-c h"))
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))

(setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
      helm-buffers-fuzzy-matching           t ; fuzzy matching buffer names when non--nil
      helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
      helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
      helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
      helm-ag-insert-at-point               (quote word)
      helm-ff-search-library-in-sexp        t
      helm-split-window-in-side-p           t
      helm-move-to-line-cycle-in-source     t
      helm-ff-file-name-history-use-recentf t)

;; key bindings
(global-set-key (kbd "C-x f") 'helm-find-files)
(global-set-key (kbd "C-M-l") 'dired-jump)
