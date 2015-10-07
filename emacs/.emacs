(require 'finder)

(require 'package)
(package-initialize)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)


;; General configuration

(inhibit-startup-screen t)
(dired-listing-switches "-alh")
(global-visual-line-mode t)
(initial-buffer-choice "/home/tsimon/Work/nicta")
