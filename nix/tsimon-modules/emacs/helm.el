;; Helm configuration

;; Much of this config comes from:
;; https://github.com/thierryvolpiatto/emacs-config/blob/main/init-helm.el

;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
(require 'helm)

(global-unset-key (kbd "C-c h"))
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
(define-key helm-map (kbd "TAB")  #'helm-execute-persistent-action)
(define-key helm-map (kbd "C-i")   'helm-execute-persistent-action) ; make TAB works in terminal
(define-key helm-map (kbd "C-z")   'helm-select-action) ; list actions using C-z

(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))

(setq helm-split-window-in-side-p	  t ; open helm buffer inside current window, not occupy whole other window
  helm-reuse-last-window-split-state      t ; from https://github.com/thierryvolpiatto/emacs-config/blob/main/init-helm.el
  helm-always-two-windows                 t
  helm-show-action-window-other-window    'left
  helm-use-frame-when-more-than-two-windows t
  helm-use-frame-when-no-suitable-window  t
  helm-allow-mouse                        t
  helm-visible-mark-prefix                "✓"
  helm-flx-for-helm-find-files            t ; intelligent fuzzy sorting
  helm-flx-for-helm-locate                t
  helm-buffers-fuzzy-matching	          t ; fuzzy matching buffer names when non--nil
  helm-move-to-line-cycle-in-source	  t ; move to end or beginning of source when reaching top or bottom of source.
  helm-ff-search-library-in-sexp	  t ; search for library in `require' and `declare-function' sexp.
  helm-scroll-amount		          8 ; scroll 8 lines other window using M-<next>/M-<prior>
  helm-ag-insert-at-point		  (quote word)
  helm-move-to-line-cycle-in-source	  t
  helm-ff-file-name-history-use-recentf   t)



;; Helm-bookmark
(with-eval-after-load 'helm-bookmark
  (customize-set-variable 'helm-bookmark-use-icon t)
  (customize-set-variable 'helm-bookmark-annotation-sign "✫"))


;; Helm-ring
(with-eval-after-load 'helm-ring
  (setq helm-kill-ring-threshold 1)
  
  ;; Actions for helm kill-ring
  (defun helm-ring-split-block (string)
    (with-temp-buffer
      (insert string)
      (goto-char (point-min))
      (helm-awhile (read (current-buffer))
        (kill-new (prin1-to-string it)))))

  (defun helm-kill-ring-insert-hunk (hunk)
    "Yank string HUNK copied from a diff buffer."
    (helm-kill-ring-action-yank-1
     (with-temp-buffer
       (insert hunk)
       (goto-char (point-min))
       (while (re-search-forward "^[+-]" nil t)
         (replace-match ""))
       (buffer-string))))

  (add-to-list 'helm-kill-ring-actions '("Split block" . helm-ring-split-block) t)
  (add-to-list 'helm-kill-ring-actions '("Insert hunk" . helm-kill-ring-insert-hunk) t)
  (define-key helm-kill-ring-map (kbd "C-d") 'helm-kill-ring-run-persistent-delete))


;; Helm-files
(with-eval-after-load 'helm-files
  (setq helm-ff-auto-update-initial-value        t
        helm-ff-allow-non-existing-file-at-point t
        helm-trash-remote-files                  t
        helm-dwim-target                         'next-window
        helm-locate-recursive-dirs-command "locate -i -e --regex '^%s' '%s.*$'"
        helm-ff-eshell-unwanted-aliases '("sudo" "cdu" "man"
                                          "gpg-pubkey-export-armor" "gpg-secretkey-export-armor")
        helm-file-name-history-hide-deleted t
        helm-ff-ignore-following-on-directory t
        helm-rsync-progress-bar-function #'helm-rsync-svg-progress-bar)
  (customize-set-variable 'helm-find-files-ignore-diacritics t)

  (define-key helm-read-file-map (kbd "RET") 'helm-ff-RET)
  (define-key helm-find-files-map (kbd "C-i") nil)
  (define-key helm-find-files-map (kbd "C-d") 'helm-ff-persistent-delete))
  
;; Helm-find
(global-set-key (kbd "C-/") 'helm-find)
(with-eval-after-load 'helm-find
  (setq helm-find-noerrors t
        helm-find-show-full-path-fn #'file-relative-name))




;; key bindings
(global-set-key (kbd "C-h r") 'helm-info-emacs)
(global-set-key (kbd "C-h d") 'helm-info-at-point)
(global-set-key (kbd "C-h i") 'helm-info)


(global-unset-key (kbd "C-x f"))
(global-set-key (kbd "C-x f") 'helm-find-files)

(global-unset-key (kbd "C-x C-d"))
(global-set-key (kbd "C-x C-d") 'helm-browse-project)

(global-set-key (kbd "C-M-l") 'dired-jump)
(global-set-key (kbd "S-<f4>") 'helm-execute-kmacro)

(global-unset-key (kbd "M-x"))
(global-set-key (kbd "M-x") 'helm-M-x)

(global-unset-key (kbd "M-y"))
(global-set-key (kbd "M-y") 'helm-show-kill-ring)


(setq helm-autoresize-max-height 50)
(setq helm-autoresize-min-height 50)
(helm-autoresize-mode 1)

(helm-mode 1)
(helm-flx-mode 1)
(helm-fuzzier-mode 1)

(setq helm-completing-read-handlers-alist
      '((find-tag . helm-completing-read-default-find-tag)
        (find-file)
        (execute-extended-command)
        (shell) ; Fixed by c04b867a but completion is useless here.
        (dired-do-rename . helm-read-file-name-handler-1)
        (dired-do-copy . helm-read-file-name-handler-1)
        (dired-do-symlink . helm-read-file-name-handler-1)
        (dired-do-relsymlink . helm-read-file-name-handler-1)
        (dired-do-hardlink . helm-read-file-name-handler-1)
        (dired-do-touch . nil)
        (read-multiple-choice--long-answers . nil)
        (basic-save-buffer . helm-read-file-name-handler-1)
        (write-file . (default helm-read-file-name-handler-1))))



(message "Helm configuration loaded")
