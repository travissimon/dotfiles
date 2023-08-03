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

(tool-bar-mode -1)
(menu-bar-mode -1)
;; (toggle-scroll-bar -1)


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

;; disable backup files, etc
(setq no-littering-etc-directory
	  (expand-file-name "backup/config/" user-emacs-directory))
(setq no-littering-var-directory
	  (expand-file-name "backup/data/" user-emacs-directory))

(use-package no-littering
  :ensure t)

(setq make-backup-files t
      vc-make-backup-files t
      version-control t
      kept-new-versions 128
      kept-old-versions 0
      delete-old-versions t
      backup-by-copying t)

(defun force-backup-of-buffer ()
  (setq buffer-backed-up nil))
(add-hook 'before-save-hook #'force-backup-of-buffer)

;;(use-package backup-walker
;;  :ensure t)
