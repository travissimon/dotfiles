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

;; Disable backup and auto-save files
(setq auto-save-default nil)
(setq make-backup-files nil)
(setq create-lockfiles nil)

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
