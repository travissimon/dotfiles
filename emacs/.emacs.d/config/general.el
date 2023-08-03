;; interface configuration

;; general visual elements
(setq inhibit-startup-screen t)
(setq dired-listing-switches "-alh")
(setq linum-mode t)
(setq global-linum-mode t)
(setq global-visual-line-mode t)
(setq initial-buffer-choice "/home/tsimon/Work/regsoft/src")
(setq visible-bell nil
	  ring-bell-function #'ignore)
(setq recenter-display nil)

(if (display-graphic-p)
  (tool-bar-mode -1)
  (menu-bar-mode -1))


;; use y-or-n settings
(fset 'yes-or-no-p 'y-or-n-p)

;; use tabs, of course
(setq-default tab-width 4)
(setq indent-tabs-mode t)


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

(setq backup-directory-alist '(("." . "~/.emacs.d/backup/")))

(setq backup-by-copying t    ; Don't delink hardlinks
      delete-old-versions t  ; Clean up the backups
      version-control t      ; Use version numbers on backups,
      kept-new-versions 5    ; keep some new versions
      kept-old-versions 2)   ; and some old ones, too
