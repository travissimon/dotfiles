;; interface configuration


;; general visual elements
(setq inhibit-startup-screen t)
(setq dired-listing-switches "-alh")
(setq linum-mode t)
(setq global-linum-mode t)
(setq global-visual-line-mode t)
(setq initial-buffer-choice "/home/tsimon/")
(setq visible-bell t)

;; use y-or-n settings
(fset 'yes-or-no-p 'y-or-n-p)

;; use tabs, of course
(setq-default tab-width 4)
(setq indent-tabs-mode t)

;; Backup file settings
(defvar --backup-directory (concat user-emacs-directory "backups"))
(if (not (file-exists-p --backup-directory))
	(make-directory --backup-directory t))
(setq backup-directory-alist `(("." . ,--backup-directory)))
(setq make-backup-files t
	  backup-by-copying t
	  version-control t
	  delete-old-versions t
	  delete-by-moving-to-trash t
	  kept-old-versions 6
	  kept-new-versions 9
	  auto-save-default t
	  auto-save-timeout 20
	  auto-save-interval 200)

(defun remove-dos-eol ()
  "Do not show ^M in files containing mixed unix & dos line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))

(remove-dos-eol)

;; undo tree
(use-package undo-tree
  :ensure t)

(global-undo-tree-mode)


