;;;
;; Packages
;;;;

;; Define package repositories
(require 'package)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)

;; Load and activate emacs packages. Do this first so that the
;; packages are loaded before you start trying to modify them.
;; This also sets the load path.
(package-initialize)

(load "/home/tsimon/general.el")
(load "/home/tsimon/themes.el")
(load "/home/tsimon/helm.el")
(load "/home/tsimon/dev.el")
(load "/home/tsimon/dev-html.el")
(load "/home/tsimon/dev-js.el")
(load "/home/tsimon/dev-typescript.el")
(load "/home/tsimon/dev-clojure.el")
