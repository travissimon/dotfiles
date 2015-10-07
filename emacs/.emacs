(require 'finder)

(require 'package)
(package-initialize)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)


;; General configuration

(inhibit-startup-screen t)
(dired-listing-switches "-alh")
(global-linum-mode 1)
(global-visual-line-mode t)
(initial-buffer-choice "/home/tsimon/Work/nicta")

;; tabs
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
      auto-save-interval 200
      )

